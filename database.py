import sqlite3
import json
from datetime import datetime

# ==============================================================================
# 📡 SBRBIOFORGE OFFLINE LOCAL DATABASE SYSTEM v1.0
# ==============================================================================

class SbrOfflineDatabase:
    def __init__(self, db_name="sbr_offline_vault.db"):
        """फोन के अंदर एक सुरक्षित डेटाबेस फाइल बनाता है"""
        self.db_name = db_name
        self.init_db()

    def init_db(self):
        """हवा, पानी और स्वास्थ्य के डेटा को स्टोर करने के लिए टेबल बनाना"""
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        
        # टेबल: जो बिना इंटरनेट के अगले 30 दिन का डेटा सुरक्षित रखेगी
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS offline_predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date_text TEXT,
                location TEXT,
                air_quality_data TEXT,
                water_level_data TEXT,
                health_guidelines TEXT,
                last_synced TEXT
            )
        ''')
        conn.commit()
        conn.close()
        print("💾 SBR LOCAL DATABASE: सुरक्षित ऑफलाइन टेबल तैयार है।")

    def sync_new_data(self, location, aqi, water, health_tips):
        """जब इंटरनेट आए, तब नया डेटा फोन में ओवरराइट/सेव करने के लिए"""
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        
        # पुराना डेटा साफ करके एकदम फ्रेश डेटा डालना
        cursor.execute("DELETE FROM offline_predictions WHERE location = ?", (location,))
        
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        cursor.execute('''
            INSERT INTO offline_predictions (date_text, location, air_quality_data, water_level_data, health_guidelines, last_synced)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', ("Next 30 Days Forecast", location, aqi, water, health_tips, current_time))
        
        conn.commit()
        conn.close()
        print(f"🔄 SBR SYNC SUCCESS: {location} का डेटा ऑफलाइन इस्तेमाल के लिए महफूज़ कर दिया गया है।")

    def fetch_offline_data(self, location):
        """इंटरनेट बंद होने पर लोगों की मदद के लिए डेटा निकालना"""
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT air_quality_data, water_level_data, health_guidelines, last_synced 
            FROM offline_predictions 
            WHERE location = ?
        ''', (location,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                "status": "Success",
                "air_quality": row[0],
                "water_level": row[1],
                "guidelines": row[2],
                "last_sync_time": row[3]
            }
        else:
            return None

# ==============================================================================
# 🎯 डेटाबेस की जांच करने का सिम्युलेटर (यह देखने के लिए कि यह कैसे काम करेगा)
# ==============================================================================
if __name__ == "__main__":
    # डेटाबेस एक्टिव करें
    sbr_db = SbrOfflineDatabase()
    
    # सिम्युलेटर 1: मान लेते हैं नेट चल रहा है और हमने नासा/मौसम API से डेटा लेकर फोन में सेव कर दिया
    print("\n--- सीन 1: इंटरनेट चालू है (डेटा सिंक हो रहा है) ---")
    sbr_db.sync_new_data(
        location="Palwal/Haryana",
        aqi="AQI: 65 (साफ हवा, सांस लेने के लिए सुरक्षित)",
        water="Water Level: भूमिगत जल सामान्य है। अगले 15 दिन पानी की कमी नहीं होगी।",
        health_tips="बदलते मौसम में बच्चों को ठंडी हवा से बचाएं। ताज़ा पानी पीएं।"
    )
    
    # सिम्युलेटर 2: अब इंटरनेट पूरी तरह बंद हो गया और यूजर ने ऐप खोला
    print("\n--- सीन 2: इंटरनेट पूरी तरह बंद है (ऑफलाइन मोड एक्टिव) ---")
    offline_report = sbr_db.fetch_offline_data("Palwal/Haryana")
    
    if offline_report:
        print("\n================ 📱 SBR OFFLINE SCREEN RENDER ================")
        print(f"📍 लोकेशन: Palwal/Haryana")
        print(f"💨 हवा की स्थिति: {offline_report['air_quality']}")
        print(f"💧 पानी का स्तर: {offline_report['water_level']}")
        print(f"🛡️ सुरक्षा गाइडलाइन: {offline_report['guidelines']}")
        print(f"🕒 आखिरी बार सिंक हुआ था: {offline_report['last_sync_time']}")
        print("==============================================================")
    else:
        print("❌ कोई ऑफलाइन डेटा नहीं मिला।")
      
