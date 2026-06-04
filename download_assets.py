import os
import re
import urllib.request
import concurrent.futures

html_file = 'index.html'
with open(html_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Find all URLs in href and src attributes
urls = re.findall(r'(https?://[^\s\'">]+\.(?:png|jpg|jpeg|svg|glb|ico))', content)
urls += re.findall(r'(https?://files\.peachworlds\.com/[^\s\'">]+)', content)
urls = list(set(urls))

if not os.path.exists('assets'):
    os.makedirs('assets')

def download_asset(url):
    try:
        filename = url.split('/')[-1].split('?')[0]
        # Include part of path to avoid name collisions
        safe_name = url.split('/')[-2] + '_' + filename if 'peachworlds' in url else filename
        local_path = f"assets/{safe_name}"
        
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(local_path, 'wb') as out_file:
            out_file.write(response.read())
        return url, local_path
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return url, None

print(f"Found {len(urls)} external assets to download...")

# Fast concurrent download
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = executor.map(download_asset, urls)

for url, local_path in results:
    if local_path:
        content = content.replace(url, local_path)

# Download relative assets
relative_urls = ['/social.jpg', '/favicon.ico']
for r_url in relative_urls:
    try:
        url = f"https://huge-5qpgs73fuc.peachweb.site{r_url}"
        filename = r_url.strip('/')
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(filename, 'wb') as out_file:
            out_file.write(response.read())
    except Exception as e:
        pass

with open(html_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Finished downloading all assets and updated index.html!")
