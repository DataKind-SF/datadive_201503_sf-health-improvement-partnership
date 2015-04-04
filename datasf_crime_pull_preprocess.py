"""
Code to pull DataSF.org Crime data and preprocess it on a scheduled basis with Linux crond.  UNTESTED.  More annotation pending.
"""

import pandas as pd
import requests
import json
import pyproj
import sys
from time import time

def main():
    """

    """
    # pull json of Crime... from datasf.org
    #TODO have a backup file
    t0 = time()
    try:
        # jsonurl = 'https://data.sfgov.org/api/views/gxxq-x39z/rows.json?accessType=DOWNLOAD'
        # os.system("wget " + jsonurl + " > out.json")
        d = requests.get('https://data.sfgov.org/api/views/gxxq-x39z/rows.json?accessType=DOWNLOAD', timeout=20)
    except Exception as e:
        sys.stderr.write(e.message)
        pass
    # # read result of wget pull
    # with open("rows.json?accessType=DOWNLOAD.1") as f:
    #     data = f.read()
    print ("time to extract data from website: %f" % (time() - t0))
    t0 = time()

    data = json.loads(d.text)
    columns = [data["meta"]["view"]["columns"][i]['fieldName'].replace(":", "") for i in
               range(len(data["meta"]["view"]["columns"]))]
    df = pd.DataFrame(data["data"], columns=columns)

    print ("time to create data frame: %f" % (time() - t0))
    t0 = time()

    # Merge date and time
    for i in ['date', 'time']:
        if df[i].dtype == 'datetime64[ns]':
            df[i] = [str(x) for x in df[i]]

    df['datetime'] = None

    df.datetime = [x[0:10] + ' ' + y for x, y in zip(df.date, df.time)]
    del df['date']
    del df['time']

    df.datetime = pd.to_datetime(df.datetime, format='%Y-%m-%d %H:%M')

    print ("time to merge and remove date-time: %f" % (time() - t0))
    t0 = time()

    df = df.sort(columns=['incidntnum', 'datetime']).reset_index(drop=True)

    # Cut resolution
    unrelated_res = ['UNFOUNDED', 'CLEARED-CONTACT JUVENILE FOR MORE INFO', 'EXCEPTIONAL CLEARANCE']
    df = df[~df.resolution.isin(unrelated_res)].reset_index(drop=True)

    # Cut all before 2010
    df = df[df.datetime > pd.to_datetime('2010', format='%Y')].reset_index(drop=True)

    # Cut Category (s)
    related_cat = ['SUICIDE', 'SEX OFFENSES, FORCIBLE', 'ASSAULT', 'ROBBERY', 'WEAPON LAWS', 'DRUG/NARCOTIC',
                 'DRUNKENNESS', 'DRIVING UNDER THE INFLUENCE', 'DISORDERLY CONDUCT', 'LIQUOR LAWS',
                 'VANDALISM', 'FAMILY OFFENSES', 'PROSTITUTION', 'SEX OFFENSES, NON FORCIBLE', 'TRESPASS',
                 'LOITERING', 'SUSPICIOUS OCC']

    df = df[df.category.isin(related_cat)].reset_index(drop=True)

    # Throw out garbage columns
    relevant_param = ['incidntnum', 'category', 'descript', 'dayofweek', 'pddistrict', 'resolution', 'address', 'x', 'y',
                 'datetime']
    df = df[relevant_param]

    print ("time to remove unnecessary columns: %f" % (time() - t0))
    t0 = time()

    crimes = {
            "violence": ['SEX OFFENSES, FORCIBLE', 'SEX OFFENSES, NON FORCIBLE', 'ASSAULT', 'ROBBERY', 'WEAPON LAWS', 'SUICIDE',
                         'FAMILY OFFENSES'],
             "vandalism": ['SUSPICIOUS OCC', 'VANDALISM', 'TRESPASS'],
             "drugs": ['DRUG/NARCOTIC'],
             "alcohol": ['LIQUOR LAWS', 'DRUNKENNESS', 'DISORDERLY CONDUCT', 'LOITERING'],
             "prostitution": ['PROSTITUTION'],
             "dui": ['DRIVING UNDER THE INFLUENCE']}

    df['CoarseCategory'] = None
    for crime in crimes:
        for crime_type in crimes[crime]:
            df.CoarseCategory[df.category == crime_type] = crime

    print ("time to create coarse categories: %f" % (time() - t0))
    t0 = time()

    # Call Nick's function with RPy2
    isn2004 = pyproj.Proj(
        "+proj=lcc +lat_1=38.43333333333333 +lat_2=37.06666666666667 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
    df.x = df.x.astype(float)
    df.y = df.y.astype(float)

    tmp = [isn2004(df.x[i], df.y[i]) for i in range(len(df))]
    tmp = zip(*tmp)
    df["newx"] = tmp[0]
    df["newy"] = tmp[1]

    print ("time to create project long and lat to new coordinates: %f" % (time() - t0))
    t0 = time()
    df.to_csv("final_data.csv", index=False, encoding='utf-8')
    print ("time to write to csv: %f" % (time() - t0))


if __name__ == '__main__':
    main()


