"""
Code to pull DataSF.org Crime data and preprocess it on a scheduled basis with Linux crond.  UNTESTED.  More annotation pending.
"""

import pandas as pd
import os
import urllib2
import numpy as np
import json
import pyproj

def main():
    """

    """
    # pull json of Crime... from datasf.org
    jsonurl  = 'https://data.sfgov.org/api/views/gxxq-x39z/rows.json?accessType=DOWNLOAD'
    os.system("wget "+jsonurl+" > out.json")
    
    # read result of wget pull
    with open("out.json") as f:
        data = f.read()

    data    = json.loads(data)
    columns = [data["meta"]["view"]["columns"][i]['fieldName'].replace(":","") for i in range(len(data["meta"]["view"]["columns"]))]
    df      = pd.DataFrame(data["data"], columns=columns)

    # Merge date and time
    for i in ['date', 'time']:
        if df[i].dtype == 'datetime64[ns]':
            df[i] = [str(x) for x in df[i]]

    df['datetime'] = None

    df.datetime = [x[0:10]+' '+y for x,y in zip(df.date,df.time)]
    del df['date']
    del df['time']

    df.datetime = pd.to_datetime(df.datetime, format = '%Y-%m-%d %H:%M')

    df = df.sort(columns =['incidntnum', 'datetime']).reset_index(drop = True)

    # Cut resolution
    these = ['UNFOUNDED', 'CLEARED-CONTACT JUVENILE FOR MORE INFO', 'EXCEPTIONAL CLEARANCE']
    df    = df[~df.resolution.isin(these)].reset_index(drop = True)

    # Cut all before 2010
    df = df[df.datetime > pd.to_datetime('2010', format = '%Y')].reset_index(drop = True)

    # Cut Category (s)
    keepthese = ['SUICIDE','SEX OFFENSES, FORCIBLE','ASSAULT','ROBBERY','WEAPON LAWS','DRUG/NARCOTIC',\
                 'DRUNKENNESS','DRIVING UNDER THE INFLUENCE','DISORDERLY CONDUCT','LIQUOR LAWS',\
                 'VANDALISM','FAMILY OFFENSES','PROSTITUTION','SEX OFFENSES, NON FORCIBLE','TRESPASS',\
                 'LOITERING','SUSPICIOUS OCC']

    df = df[df.category.isin(keepthese)].reset_index(drop = True)

    # Throw out garbage columns
    keepthese = ['incidntnum','category','descript','dayofweek','pddistrict','resolution','address','x','y','datetime']
    df        = df[keepthese]

    # add Coarse Category
    violence     = ['SEX OFFENSES, FORCIBLE', 'SEX OFFENSES, NON FORCIBLE','ASSAULT','ROBBERY','WEAPON LAWS','SUICIDE', 'FAMILY OFFENSES']
    vandalism    = ['SUSPICIOUS OCC', 'VANDALISM', 'TRESPASS']
    drugs        = ['DRUG/NARCOTIC']
    alcohol      = ['LIQUOR LAWS','DRUNKENNESS','DISORDERLY CONDUCT', 'LOITERING']  
    prostitution = ['PROSTITUTION']
    dui          = ['DRIVING UNDER THE INFLUENCE']

    df['CoarseCategroy'] = None
    for i in df.index:
        if df.category[i] in violence:
            df['CoarseCategroy'][i] = 'violence'
        if df.category[i] in vandalism:
            df['CoarseCategroy'][i] = 'vandalism'
        if df.category[i] in drugs:
            df['CoarseCategroy'][i] = 'drugs'
        if df.category[i] in alcohol:
            df['CoarseCategroy'][i] = 'alcohol'
        if df.category[i] in prostitution:
            df['CoarseCategroy'][i] = 'prostitution'
        if df.category[i] in dui:
            df['CoarseCategroy'][i] = 'dui'

    # add Coarse descriptor Kris code....





    # Call Nick's function with RPy2
    isn2004=pyproj.Proj("+proj=lcc +lat_1=38.43333333333333 +lat_2=37.06666666666667 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
    df.x = df.x.astype(float)
    df.y = df.y.astype(float)
    
    tmp = [isn2004(df.x[i],df.y[i]) for i in range(len(df))]
    tmp = zip(*tmp)
    df["newx"] = tmp[0]
    df["newy"] = tmp[1]

    return df


if __name__ == '__main__':
    main()


