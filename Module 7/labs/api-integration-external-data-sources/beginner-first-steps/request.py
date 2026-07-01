import requests
import time
import os
from dotenv import load_dotenv

load_dotenv()

imf_url = "https://www.imf.org/external/datamapper/api/v2/NGDP_RPCH/LSO,ZAF,BWA,USA"
bis_url = "https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/D.ZA"

timeout = 10

def wait_before_request(seconds=10):
    print(f"Waiting for {seconds}")
    time.sleep(seconds)

def build_header(accept_type):
    headers = {
    "Accept": accept_type
    }

    api_key = os.getenv("API_KEY")

    if api_key:
        headers["Authorization"] = f"bearer {api_key}"
    
    return headers

def get_imf_json():
    wait_before_request(1)

    params = {
    "periods": "2024,2025,2026"
    }
    
    response = requests.get(
        imf_url,
        params= params,
        headers=build_header("application/json"),
        timeout=timeout
    )
    response.raise_for_status() 

    name = 'Andrew'
    city = 'Cape Town'
    print(f"My nameis %s and l live in %s", name, city )

    print("IMF API call executed", response.status_code)

    return response.json()

def get_bis_xml():
    wait_before_request(1)

    params = {
    "startPeriod": "2024-01",
    "endPeriod": "2024-12",
    "detail": "full"
    }
    
    response = requests.get(
        imf_url,
        params= params,
        headers=build_header("application/xml"),
        timeout=timeout
    )

    response.raise_for_status()
    print("IMF API call executed", response.status_code)

    return response.json()

def main():
    imf_data = get_imf_json()
    bis_dat = get_bis_xml()

if __name__ == "__main__":
    main()