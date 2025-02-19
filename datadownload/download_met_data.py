
import pandas as pd
import os
import gzip
import requests

site_path = r'E:\气象数据\metoffice\siteinfo.txt'
# 首先读取数据，筛选经纬度范围内的站点。
site = pd.read_csv(site_path, delim_whitespace=True, header=None, names=['id', 'latitude', 'longitude', 'altitude'])
site_alps = site[
    (site['longitude'] > -180) & (site['longitude'] < 180) & (site['latitude'] < -90) & (site['latitude'] > 90)]
print(len(site_alps))

# 接下来我们下载数据，数据的是经过 Gzip（GNU zip）压缩算法进行压缩的nc数据。
save_folder_path = r'E:\气象数据\metoffice\folder'
os.makedirs(save_folder_path, exist_ok=True)
for site_id in site_alps['id']:
    # filenum = len(os.listdir(save_folder_path))
    # print(filenum)
    download_url = f'https://www.metoffice.gov.uk/hadobs/hadisd/v341_202410p/data/hadisd.3.4.1.202410p_19310101-20241101_{site_id}.nc.gz'
    response = requests.get(download_url)
    response.raise_for_status()
    download_file_path = os.path.join(save_folder_path, f'{site_id}.nc.gz')
    with open(download_file_path, 'wb') as file:
        file.write(response.content)
        print(f'site {site_id} saved')

# 下载之后对压缩包进行解压并且删除。
folder_path = r'E:\气象数据\metoffice\folder'
save_path = r'E:\气象数据\metoffice\global_met_data_nc'
for filename in os.listdir(folder_path):
    if filename.endswith('.nc.gz'):
        file_path = os.path.join(folder_path, filename)
        with gzip.open(file_path, 'rb') as gz_file:
            filename_nc = os.path.splitext(filename)[0]
            file_path_nc = os.path.join(save_path, filename_nc)
            with open(file_path_nc, 'wb') as output_file:
                output_file.write(gz_file.read())
                print(f'{filename} decompressed')
                # os.remove(file_path)
                # print(f'{filename} deleted')



