
import time
import cdsapi
from datetime import datetime, timedelta

c = cdsapi.Client()
# 数据下载函数
# def download_era5_data(date):
#     date_str = date.strftime('%Y-%m-%d')
#
#     filename = f'D:/代码/ERA5/era5_data/global_era5-{date_str}.nc'
#
#     c.retrieve(
#         'reanalysis-era5-pressure-levels',
#         {
#             'product_type': 'reanalysis',
#             'variable': [
#                 'geopotential', 'relative_humidity', 'specific_humidity', 'temperature',
#             ],
#             'pressure_level': [
#                 '1', '2', '3', '5', '7', '10',
#                 '20', '30', '50', '70', '100', '125',
#                 '150', '175', '200', '225', '250', '300',
#                 '350', '400', '450', '500', '550', '600',
#                 '650', '700', '750', '775', '800', '825',
#                 '850', '875', '900', '925', '950', '975',
#                 '1000',
#             ],
#             'year': date.year,
#             'month': date.month,
#             'day': date.day,
#             'time': ['00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'],
#             'area': [90, -180, -90, 180],
#             'format': 'netcdf',
#         },
#         filename
#     )
#     print(f"Data for {date_str} downloaded.")

def download_era5_data(date, retries=3):
    date_str = date.strftime('%Y-%m-%d')
    
    filename = f'D:/era5_data/global_era5-{date_str}.nc'

    for attempt in range(retries):
        try:
            c.retrieve(
                'reanalysis-era5-pressure-levels',
                {
                    'product_type': 'reanalysis',
                    'variable': [
                        'geopotential', 'relative_humidity', 'specific_humidity', 'temperature',
                    ],
                    'pressure_level': [
                        '1', '2', '3', '5', '7', '10',
                        '20', '30', '50', '70', '100', '125',
                        '150', '175', '200', '225', '250', '300',
                        '350', '400', '450', '500', '550', '600',
                        '650', '700', '750', '775', '800', '825',
                        '850', '875', '900', '925', '950', '975',
                        '1000',
                    ],
                    'year': date.year,
                    'month': date.month,
                    'day': date.day,
                    'time': ['00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'],
                    'area': [90, -180, -90, 180],
                    'format': 'netcdf',
                },
                filename
            )
            print(f"数据 {date_str} 下载成功。")
            break  # 如果下载成功，跳出重试循环
        except Exception as e:
            print(f"第 {attempt + 1} 次下载失败: {e}")
            if attempt < retries - 1:
                print("正在重试...")
                time.sleep(3)  # 等待5秒后再重试
            else:
                print(f"下载 {date_str} 数据失败，已尝试 {retries} 次。")




# 定义下载时间范围: 2020-01-01 —> 2024-01-01
start_date = datetime(2020, 01, 01)
end_date = datetime(2024, 01, 01)
current_date = start_date

while current_date <= end_date:
    download_era5_data(current_date)
    current_date += timedelta(days=1)



