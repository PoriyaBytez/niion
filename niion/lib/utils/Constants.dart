const appName = "Niion";
const localDbName = "niion_app";
const apiKeyWeather = "73079826800d40478bf191604230501";
const batteryRange = 100;
const batteryThreshold1 = 20;
const batteryThreshold2 = 10;
const double initialLocVariation =
    1.0; //Reset polyline is diff. bet. initial marker and 2nd marker is > 1Km

//config Data
const contactNumber = "7879287257";
const contactEmail = "support@Niion.in";
const contactLatLon = "17.4223725,78.3342633";

//URLs
const weatherAPI = "https://api.weatherapi.com/v1/current.json";
const shopOurProductsAPI = "https://niion.in/";
const tncAPI = "https://niion.in/pages/terms-conditions";
const ppAPI = "https://niion.in/pages/privacy-policy";
const faqAPI = "https://niion.in/pages/faqs";
const aboutUsAPI = "https://niion.in/pages/about-us";
const whatsappAPI = "https://api.whatsapp.com/send/?phone=91$contactNumber&text=Hi";

//Prefs
const prefBatteryRange = "batteryRange";
const prefBatteryResetTime = "batteryResetTime";
const prefIsLoggedIn = "isLoggedIn";
const prefUserName = "userName";
const prefUserEmail = "userEmail";
const prefUserNumber = "userNumber";

// Day-3 (6 Hours)
// var response = await postRequestList("https://api.weatherapi.com/v1/current.json", <String>["key",apiKeyWeather, "q", "Hyderabad"]);
// log(response.body);

// saveLocal("key3", "Nikzu");
// getLocal("key3");
// Location Permissions
// Geo-Location with co-ordinates for Weather API

// var map = <String, dynamic>{};
// map["key"] = apiKeyWeather;
// map["q"] = "Hyderabad";
// var response = await postRequestMap("https://api.weatherapi.com/v1/current.json", map);
// log(response.body);
// Map parsed = jsonDecode(response.body);
// var city = parsed["location"]["name"];
// var time = parsed["location"]["localtime_epoch"];
// var temp = parsed["current"]["temp_c"];
// var desc = parsed["current"]["condition"]["text"];
// var icon = parsed["current"]["condition"]["icon"];

// Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
// var weather = await getWeather(position.latitude, position.longitude);
// print(
// "weatherInfo\nName=${weather?.location?.name}\nLat=${weather?.location?.lat}\n"
// "Lon=${weather?.location?.lon}\nRegion=${weather?.location?.region}\n"
// "Time=${weather?.location?.localtimeEpoch}\nTemp=${weather?.current?.tempC}\n"
// "Desc=${weather?.current?.condition?.text}\nIcon=${weather?.current?.condition?.icon}\n");

// Day-2 (4 Hours)
// showToast("Nikhil Reddy Sandiri");
// showSnack(context, "Hey Niks");
// showAlert(context, false, "Tit", "I'm the text");
// openScreen(context, const SecondRoute());

// Day-1 (6 Hours)
// launchUrl(Uri.parse("tel://+917879287257"));
