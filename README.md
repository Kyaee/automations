# I'm making life easier 

Starting my process documentation on what to automate
## The Five Time Fields
Cron reads the fields from left to right. Each position represents a different unit of time:

- Minute: 0 through 59
- Hour: 0 through 23 (Midnight is 0, 11 PM is 23)
- Day of the Month: 1 through 31
- Month: 1 through 12
- Day of the Week: 0 through 7 (Both 0 and 7 stand for Sunday)

The basic structure looks like this:
```
[Minute] [Hour] [Day_of_Month] [Month] [Day_of_Week] /path/to/command
```
## Special Characters
You do not have to use just single numbers. Cron uses special characters to create flexible schedules:
| Character | Name | How it Works | Example |
| :--- | :--- | :--- | :--- |
| `*` | Asterisk | Means "every" or "any." | `*` in the hour field means every hour. |
| `,` | Comma | Separates multiple specific values. | `1,15` in the day field means the 1st and 15th. |
| `-` | Hyphen | Defines a range of values. | `9-17` in the hour field means from 9 AM to 5 PM. |
| `/` | Slash | Specifies step values or intervals. | `*/15` in the minute field means every 15 minutes. |


| Cron Expression | Human Translation |
| :--- | :--- |
| `* * * * *` | Runs every single minute. |
| `0 * * * *` | Runs at the top of every hour (Minute 0). |
| `30 14 * * 1` | Runs at 2:30 PM (Hour 14, Minute 30) every Monday (Day 1). |
| `0 0 1 * *` | Runs at midnight (0:00) on the 1st day of every month. |
| `0 8 * * 1-5` | Runs at 8:00 AM, Monday through Friday. |
| `*/10 9-17 * * *` | Runs every 10 minutes, but only between 9:00 AM and 5:59 PM. |
