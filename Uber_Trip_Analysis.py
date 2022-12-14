#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import calendar

df = pd.read_csv(r"C:\Users\babuj\Desktop\Portfolio- Data Analyst\Uber_Rides.csv")
df2 = df.iloc[:-1,:]
df2.tail()
print(df2)
df2.shape
df2.isnull().sum()
df2.dtypes
df2.columns
df2['START_DATE*'] = pd.to_datetime(df2['START_DATE*'], format="%m/%d/%Y %H:%M")
df2['END_DATE*'] = pd.to_datetime(df2['END_DATE*'], format="%m/%d/%Y %H:%M")
df2['MILES*'] = df2['MILES*'].astype('float')
df2.dtypes
df2.fillna("unknown", inplace=True)
df2.isna().sum()

#seperating date to day, day of the week, month, and time

df2['START_HOUR'] = [x.hour for x in df2['START_DATE*']]
df2['START_DAY'] = [x.day for x in df2['START_DATE*']]
df2['START_MONTH'] = [calendar.month_name[x.month] for x in df2['START_DATE*']]
df2['DAY_OF_WEEK'] = [x.dayofweek for x in df2['START_DATE*']]
df2['WEEKDAY'] = [calendar.day_name[x.dayofweek] for x in df2['START_DATE*']]
df2.head()
sns.countplot(x='CATEGORY*', data=df2)
sns.countplot(y ='PURPOSE*', data = df2, order = df2['PURPOSE*'].value_counts().index)

#Using these two graphs, it is clear that users most used Uber for business purposes and in particular for meeting and meals 
#most of the time. Other significant purposes include errands and customer visits. 
#This implies user works in a client-based service industry that demands frequent traveling and dining with clients in the city.
df2['MILES*'].plot.hist()
#This histogram shows majority of trips are short distanced eithin 50 miles

df2['START_HOUR'].value_counts().plot(kind = "bar", color = "green" ,  figsize = (10,5))
plt.xlabel('Hour in a day')
plt.ylabel('# of Trips')
plt.title('Trips vs hours')
# Most trpis are between 12 pm and 5 pm. 
#This confirms that user travels during lunch hours and in the early evenings more than the rest of the day.

#Travel patterns on different days of the week
df2['WEEKDAY'].value_counts().plot(kind="bar", color = "red",figsize = (10,5) )
plt.xlabel('Day')
plt.ylabel('# of Trips')

#month-wise distribution of Uber trips
df2['START_MONTH'].value_counts().plot(kind="bar", color = "darkblue",figsize = (10,5) )

plt.xlabel('Month')
plt.ylabel('# of Trips')
# There are significantly more trips in December 2016 for this user while the rest of the months fall within a specific range.

# December travel info
month = df2['START_DAY'][df2['START_MONTH']=='December'].value_counts()
month.plot(kind= 'bar')
plt.xlabel("Days of December")
plt.ylabel("# of Trips")
plt.title("Number of Trips vs Days of December")

#Most of the trips are in the second half of the month i.e christmas period. So these might be person trips during holiday season

# where did the user travel to and from in an Uber.
start_location = df2['START*'].value_counts().nlargest(10).sort_values()
start_location.plot(kind = 'barh' )
plt.xlabel('# of trips')
plt.ylabel('Pick Point')
plt.title("Pick point vs Frequency")

end_location = df2['STOP*'].value_counts().nlargest(10).sort_values()
end_location.plot(kind = 'barh' )
plt.xlabel('# of trips')
plt.ylabel('Drop Point')
plt.title("Drop point vs Frequency")

df2['from_to'] = df2[['START*', 'STOP*']].apply("-".join, axis=1)

pickup_drop_location = df2['from_to'].value_counts().nlargest(15).sort_values()
pickup_drop_location.plot(kind = 'barh' )
plt.xlabel('# of trips')
plt.ylabel('Pickup-Drop')
plt.title("Trips From and to vs Frequency")

