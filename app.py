import os
import json

# ==============================================================================
# 🌍 SBRBIOFORGE CENTRAL CORE ENGINE - VERSION 1.0 (FRESH START)
# ==============================================================================

class SbrBioForge:
    def __init__(self):
        # 🔒 सुरक्षा नियम: कोई भी चाबी कोड में नहीं है, सब गिटहब सीक्रेट्स से आएंगी
        self.groq_key = os.environ.get("GROQ_API_KEY")
        self.weather_water_key = os.environ.get("WEATHER_WATER_API_KEY")
        self.air_quality_key = os.environ.get("AIR_QUALITY_API_KEY")
        
    def check_internet(self):
        """चेक करता है कि यूजर के फोन में इंटरनेट है या नहीं"""
        # एंड्रॉयड ऐप में यह ऑटोमैटिक काम करेगा, अभी इसे टेस्ट करने के लिए सेट किया है
        return False  # बिना इंटरनेट (Offline Mode) की टेस्टिंग के लिए इसे False रखा है

    def get_air_and_water_solution(self, module_choice, user_location, offline_data=None):
        """
        हवा और पानी की जानकारी देने वाला मुकम्मल कस्टमाइज्ड फंक्शन
        """
        is_online = self.check_internet()
        
        if is_online:
            # 📡 ऑनलाइन मोड (जब इंटरनेट चल रहा हो)
            if not self.groq_key:
                return {"status": 500, "message": "ERROR: GitHub Secrets में API Key गायब है।"}
            
            # यहाँ भविष्य में आपकी 11 लाइव APIs का डेटा जुड़ेगा
            return {
                "status": 200,
                "mode": "Online",
                "location": user_location,
                "message": "लाइव सर्वर से हवा और पानी का सटीक डेटा लोड हो गया है।"
            }
        else:
            # ⚠️ ऑफलाइन मोड (बिना इंटरनेट के लोगों का सहारा)
            print("🟢 SBRBIOFORGE: इंटरनेट बंद है। ऑफलाइन डेटाबेस एक्टिव किया जा रहा है...")
            
            if offline_data:
                return {
                    "status": 200,
                    "mode": "Offline-First",
                    "location": user_location,
                    "sbr_guideline": "आने वाले समय के लिए सुरक्षित निर्देश: " + offline_data
                }
            else:
                return {
                    "status": 404,
                    "mode": "Offline-First",
                    "sbr_guideline": "डेटाबेस खाली है! कृपया संकट से पहले एक बार इंटरनेट चालू करके डेटा सिंक करें।"
                }

# ==============================================================================
# 🎯 सिस्टम को टेस्ट करने का रनर (सिम्युलेटर)
# ==============================================================================
if __name__ == "__main__":
    # इंजन चालू करें
    sbr_system = SbrBioForge()
    
    # मान लेते हैं यूजर के फोन की मेमोरी में यह डेटा पहले से डाउनलोड था
    saved_memory_data = "पानी का स्तर सामान्य है। हवा में प्रदूषण (AQI 52) सुरक्षित है। अगले 3 दिन पानी बचाएं।"
    
    # बिना इंटरनेट के ऐप चलाकर देखना
    output = sbr_system.get_air_and_water_solution(
        module_choice="3", 
        user_location="Delhi/NCR", 
        offline_data=saved_memory_data
    )
    
    # स्क्रीन पर परिणाम दिखाना (हिंदी और साफ भाषा में)
    print("\n=================== 🤖 SBRBIOFORGE OUTPUT ===================")
    print(json.dumps(output, ensure_ascii=False, indent=4))
    print("=============================================================")

