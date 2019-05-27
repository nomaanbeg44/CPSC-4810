#!/usr/bin/env python3

import pandas as pd
data1=pd.read_csv("flightdelays.csv")
data2=data1[data1['Origin']=='SFO']['ArrDelay'].iloc[:3]
data.to_csv('first3sfo.csv')
data3=pd.read_csv('first3sfp.csv', header=NONE)[1]
print(data3)
#top 3 destinations
print(data1['Dist'].value_counts().head(3))

print("nomaan")
