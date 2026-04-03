import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "http://api.alquran.cloud/v1/quran/en.sahih"
response = urllib.request.urlopen(url, context=ctx)
data = json.loads(response.read())

quran_array = []
surahs = data.get("data", {}).get("surahs", [])
for surah in surahs:
    chapter = surah.get("number")
    for ayah in surah.get("ayahs", []):
        quran_array.append({
            "chapter": chapter,
            "verse": ayah.get("numberInSurah"),
            "text": ayah.get("text")
        })

output_data = {"quran": quran_array}

with open("assets/translations/en_sahih.json", "w", encoding="utf-8") as f:
    json.dump(output_data, f, ensure_ascii=False, indent=4)

print("Downloaded and formatted successfully.")
