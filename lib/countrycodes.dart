const Map<String,String> countryNameRegionCode = {"Albania":"AL",
"Algeria":"DZ",
"Angola":"AO",
"Antigua and Barbuda":"AG",
"Argentina":"AR",
"Armenia":"AM",
"Aruba":"AW",
"Australia":"AU",
"Austria":"AT",
"Azerbaijan":"AZ",
"Bahamas":"BS",
"Bahrain":"BH",
"Bangladesh":"BD",
"Belarus":"BY",
"Belgium":"BE",
"Belize":"BZ",
"Benin":"BJ",
"Bermuda":"BM",
"Bolivia":"BO",
"Bosnia and Herzegovina":"BA",
"Botswana":"BW",
"Brazil":"BR",
"British Virgin Islands":"VG",
"Bulgaria":"BG",
"Burkina Faso":"BF",
"Burundi":"BI",
"Cambodia":"KH",
"Cameroon":"CM",
"Canada":"CA",
"Cape Verde":"CV",
"Cayman Islands":"KY",
"Chile":"CL",
"China":"CN",
"Colombia":"CO",
"Republic of the Congo":"CG",
"D Republic of the Congo":"CD",
"Costa Rica":"CR",
"Croatia":"HR",
"Cyprus":"CY",
"Czech Republic":"CZ",
"Denmark":"DK",
"Dominican Republic":"DO",
"Ecuador":"EC",
"Egypt":"EG",
"El Salvador":"SV",
"Estonia":"EE",
"Fiji":"FJ",
"Finland":"FI",
"France":"FR",
"Gabon":"GA",
"Georgia":"GE",
"Germany":"DE",
"Ghana":"GH",
"Greece":"GR",
"Guatemala":"GT",
"Guinea":"GN",
"Guinea-Bissau":"GW",
"Haiti":"HT",
"Honduras":"HN",
"Hong Kong":"HK",
"Hungary":"HU",
"Iceland":"IS",
"India":"IN",
"Indonesia":"ID",
"Iraq":"IQ",
"Ireland":"IE",
"Israel":"IL",
"Italy":"IT",
"Ivory Coast":"CI",
"Jamaica":"JM",
"Japan":"JP",
"Jordan":"JO",
"Kazakhstan":"KZ",
"Kenya":"KE",
"Kuwait":"KW",
"Kyrgyzstan":"KG",
"Laos":"LA",
"Latvia":"LV",
"Lebanon":"LB",
"Lesotho":"LS",
"Libya":"LY",
"Liechtenstein":"LI",
"Lithuania":"LT",
"Luxembourg":"LU",
"Macau":"MO",
"Malawi":"MW",
"Malaysia":"MY",
"Mali":"ML",
"Malta":"MT",
"Mauritania":"MR",
"Mauritius":"MU",
"Mexico":"MX",
"Moldova":"MD",
"Morocco":"MA",
"Mozambique":"MZ",
"Myanmar":"MM",
"Namibia":"NA",
"Nepal":"NP",
"Netherlands":"NL",
"New Zealand":"NZ",
"Nicaragua":"NI",
"Niger":"NE",
"Nigeria":"NG",
"Macedonia":"MK",
"Oman":"OM",
"Pakistan":"PK",
"Panama":"PA",
"Papua New Guinea":"PG",
"Paraguay":"PY",
"Peru":"PE",
"Philippines":"PH",
"Poland":"PL",
"Portugal":"PT",
"Qatar":"QA",
"Romania":"RO",
"Russia":"RU",
"Rwanda":"RW",
"Saudi Arabia":"SA",
"Senegal":"SN",
"Serbia":"RS",
"Singapore":"SG",
"Slovakia":"SK",
"Slovenia":"SI",
"South Africa":"ZA",
"South Korea":"KR",
"Spain":"ES",
"Sri Lanka":"LK",
"Sweden":"SE",
"Switzerland":"CH",
"Taiwan":"TW",
"Tajikistan":"TJ",
"Tanzania":"TZ",
"Thailand":"TH",
"Togo":"TG",
"Trinidad and Tobago":"TT",
"Tunisia":"TN",
"Turkey":"TR",
"Turkmenistan":"TM",
"Turks and Caicos Islands":"TC",
"Uganda":"UG",
"Ukraine":"UA",
"United Arab Emirates":"AE",
"United Kingdom":"GB",
"United States":"US",
"Uruguay":"UY",
"Uzbekistan":"UZ",
"Venezuela":"VE",
"Vietnam":"VN",
"Yemen":"YE",
"Zambia":"ZM",
"Zimbabwe":"ZW"};
const Map<String,String> regionCodeCountryCode = {"AL":"+355",
"DZ":"+213",
"AO":"+244",
"AG":"+1268",
"AR":"+54",
"AM":"+374",
"AW":"+297",
"AU":"+61",
"AT":"+43",
"AZ":"+994",
"BS":"+1242",
"BH":"+973",
"BD":"+880",
"BY":"+375",
"BE":"+32",
"BZ":"+501",
"BJ":"+229",
"BM":"+1441",
"BO":"+591",
"BA":"+387",
"BW":"+267",
"BR":"+55",
"VG":"+1284",
"BG":"+359",
"BF":"+226",
"BI":"+257",
"KH":"+855",
"CM":"+237",
"CA":"+1",
"CV":"+238",
"KY":"+1345",
"CL":"+56",
"CN":"+86",
"CO":"+57",
"CG":"+242",
"CD":"+243",
"CR":"+506",
"HR":"+385",
"CY":"+357",
"CZ":"+420",
"DK":"+45",
"DO":"+1809",
"EC":"+593",
"EG":"+20",
"SV":"+503",
"EE":"+372",
"FJ":"+679",
"FI":"+358",
"FR":"+33",
"GA":"+241",
"GE":"+995",
"DE":"+49",
"GH":"+233",
"GR":"+30",
"GT":"+502",
"GN":"+224",
"GW":"+245",
"HT":"+509",
"HN":"+504",
"HK":"+852",
"HU":"+36",
"IS":"+354",
"IN":"+91",
"ID":"+62",
"IQ":"+964",
"IE":"+353",
"IL":"+972",
"IT":"+39",
"CI":"+225",
"JM":"+1876",
"JP":"+81",
"JO":"+962",
"KZ":"+7",
"KE":"+254",
"KW":"+965",
"KG":"+996",
"LA":"+856",
"LV":"+371",
"LB":"+961",
"LS":"+266",
"LY":"+218",
"LI":"+423",
"LT":"+370",
"LU":"+352",
"MO":"+853",
"MW":"+265",
"MY":"+60",
"ML":"+223",
"MT":"+356",
"MR":"+222",
"MU":"+230",
"MX":"+52",
"MD":"+373",
"MA":"+212",
"MZ":"+258",
"MM":"+95",
"NA":"+264",
"NP":"+977",
"NL":"+31",
"NZ":"+64",
"NI":"+505",
"NE":"+227",
"NG":"+234",
"MK":"+389",
"OM":"+968",
"PK":"+92",
"PA":"+507",
"PG":"+675",
"PY":"+595",
"PE":"+51",
"PH":"+63",
"PL":"+48",
"PT":"+351",
"QA":"+974",
"RO":"+40",
"RU":"+7",
"RW":"+250",
"SA":"+966",
"SN":"+221",
"RS":"+381",
"SG":"+65",
"SK":"+421",
"SI":"+386",
"ZA":"+27",
"KR":"+82",
"ES":"+34",
"LK":"+94",
"SE":"+46",
"CH":"+41",
"TW":"+886",
"TJ":"+992",
"TZ":"+255",
"TH":"+66",
"TG":"+228",
"TT":"+1868",
"TN":"+216",
"TR":"+90",
"TM":"+993",
"TC":"+1649",
"UG":"+256",
"UA":"+380",
"AE":"+971",
"GB":"+44",
"US":"+1",
"UY":"+598",
"UZ":"+998",
"VE":"+58",
"VN":"+84",
"YE":"+967",
"ZM":"+260",
"ZW":"+263"
};
const Map<String,int> regionCodeNationalNumberLength = {
"AL":8,
"DZ":8,
"AO":9,
"AG":7,
"AR":10,
"AM":8,
"AW":7,
"AU":9,
"AT":10,
"AZ":9,
"BS":7,
"BH":8,
"BD":8,
"BY":9,
"BE":8,
"BZ":7,
"BJ":8,
"BM":7,
"BO":8,
"BA":8,
"BW":7,
"BR":10,
"VG":7,
"BG":7,
"BF":8,
"BI":8,
"KH":8,
"CM":9,
"CA":10,
"CV":7,
"KY":7,
"CL":9,
"CN":10,
"CO":8,
"CG":9,
"CD":7,
"CR":8,
"HR":8,
"CY":8,
"CZ":9,
"DK":8,
"DO":7,
"EC":8,
"EG":9,
"SV":8,
"EE":7,
"FJ":7,
"FI":9,
"FR":9,
"GA":7,
"GE":9,
"DE":8,
"GH":9,
"GR":10,
"GT":8,
"GN":8,
"GW":9,
"HT":8,
"HN":8,
"HK":8,
"HU":8,
"IS":7,
"IN":10,
"ID":9,
"IQ":8,
"IE":7,
"IL":8,
"IT":9,
"CI":8,
"JM":7,
"JP":9,
"JO":8,
"KZ":10,
"KE":9,
"KW":8,
"KG":9,
"LA":8,
"LV":8,
"LB":7,
"LS":8,
"LY":9,
"LI":7,
"LT":8,
"LU":8,
"MO":8,
"MW":7,
"MY":9,
"ML":8,
"MT":8,
"MR":8,
"MU":8,
"MX":10,
"MD":8,
"MA":9,
"MZ":8,
"MM":7,
"NA":8,
"NP":8,
"NL":9,
"NZ":8,
"NI":8,
"NE":8,
"NG":8,
"MK":8,
"OM":8,
"PK":10,
"PA":7,
"PG":7,
"PY":9,
"PE":8,
"PH":8,
"PL":9,
"PT":9,
"QA":8,
"RO":9,
"RU":10,
"RW":9,
"SA":9,
"SN":9,
"RS":8,
"SG":8,
"SK":9,
"SI":8,
"ZA":9,
"KR":8,
"ES":9,
"LK":9,
"SE":7,
"CH":9,
"TW":9,
"TJ":9,
"TZ":9,
"TH":8,
"TG":8,
"TT":7,
"TN":8,
"TR":10,
"TM":8,
"TC":7,
"UG":9,
"UA":9,
"AE":8,
"GB":10,
"US":10,
"UY":8,
"UZ":9,
"VE":10,
"VN":10,
"YE":7,
"ZM":9,
"ZW":7,};
const List<String> countryCodesForDropDownMenu = ["+355",
"+213",
"+244",
"+1268",
"+54",
"+374",
"+297",
"+61",
"+43",
"+994",
"+1242",
"+973",
"+880",
"+375",
"+32",
"+501",
"+229",
"+1441",
"+591",
"+387",
"+267",
"+55",
"+1284",
"+359",
"+226",
"+257",
"+855",
"+237",
"+1",
"+238",
"+1345",
"+56",
"+86",
"+57",
"+242",
"+243",
"+506",
"+385",
"+357",
"+420",
"+45",
"+593",
"+20",
"+503",
"+372",
"+679",
"+358",
"+33",
"+241",
"+995",
"+49",
"+233",
"+30",
"+502",
"+224",
"+245",
"+509",
"+504",
"+852",
"+36",
"+354",
"+91",
"+62",
"+964",
"+353",
"+972",
"+39",
"+225",
"+1876",
"+81",
"+962",
"+7",
"+254",
"+965",
"+996",
"+856",
"+371",
"+961",
"+266",
"+218",
"+423",
"+370",
"+352",
"+853",
"+265",
"+60",
"+223",
"+356",
"+222",
"+230",
"+52",
"+373",
"+212",
"+258",
"+95",
"+264",
"+977",
"+31",
"+64",
"+505",
"+227",
"+234",
"+389",
"+968",
"+92",
"+507",
"+675",
"+595",
"+51",
"+63",
"+48",
"+351",
"+974",
"+40",
"+7",
"+250",
"+966",
"+221",
"+381",
"+65",
"+421",
"+386",
"+27",
"+82",
"+34",
"+94",
"+46",
"+41",
"+886",
"+992",
"+255",
"+66",
"+228",
"+1868",
"+216",
"+90",
"+993",
"+1649",
"+256",
"+380",
"+971",
"+44",
"+598",
"+998",
"+58",
"+84",
"+967",
"+260",
"+263",
"+1809",
"+1829",
"+1849",];