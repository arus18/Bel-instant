import 'dart:math';

const List<String> fontNames = [
  "ABeeZee",
  "Abel",
  "Abhaya Libre",
  "Abril Fatface",
  "Acme",
  "Actor",
  "Adamina",
  "Advent Pro",
  "Aguafina Script",
  "Akronim",
  "Aladin",
  "Alata",
  "Alatsi",
  "Aldrich",
  "Alef",
  "Alegreya",
  "Alegreya Sans",
  "Alegreya Sans SC",
  "Alegreya SC",
  "Aleo",
  "Alex Brush",
  "Alfa Slab One",
  "Alice",
  "Alike",
  "Alike Angular",
  "Allan",
  "Allerta",
  "Allerta Stencil",
  "Allura",
  "Almarai",
  "Almendra",
  "Almendra Display",
  "Almendra SC",
  "Amarante",
  "Amaranth",
  "Amatica SC",
  "Amatic SC",
  "Amethysta",
  "Amiko",
  "Amiri",
  "Amita",
  "Anaheim",
  "Andada",
  "Andika",
  "Annie Use Your Telescope",
  "Anonymous Pro",
  "Antic",
  "Antic Didone",
  "Antic Slab",
  "Anton",
  "Arapey",
  "Arbutus",
  "Arbutus Slab",
  "Architects Daughter",
  "Archivo",
  "Archivo Black",
  "Archivo Narrow",
  "Aref Ruqaa",
  "Arima Madurai",
  "Arizonia",
  "Armata",
  "Arsenal",
  "Artifika",
  "Arvo",
  "Arya",
  "Asap",
  "Asar",
  "Asset",
  "Assistant",
  "Astloch",
  "Asul",
  "Athiti",
  "Atma",
  "Atomic Age",
  "Aubrey",
  "Audiowide",
  "Autour One",
  "Average",
  "Average Sans",
  "Averia Gruesa Libre",
  "Averia Libre",
  "Averia Sans Libre",
  "Averia Serif Libre",
  "B612",
  "B612 Mono",
  "Bad Script",
  "Bahiana",
  "Bahianita",
  "Bai Jamjuree",
  "Baloo",
  "Baloo Bhai",
  "Baloo Bhaijaan",
  "Baloo Bhaina",
  "Baloo Chettan",
  "Baloo Da",
  "Baloo Paaji",
  "Baloo Tamma",
  "Baloo Tammudu",
  "Baloo Thambi",
  "Balthazar",
  "Bangers",
  "Barlow",
  "Barlow Condensed",
  "Barlow Semi Condensed",
  "Barriecito",
  "Barrio",
  "Basic",
  "Baskervville",
  "Baumans",
  "Bebas Neue",
  "Belgrano",
  "Bellefair",
  "Belleza",
  "Bellota",
  "Bellota Text",
  "BenchNine",
  "Bentham",
  "Berkshire Swash",
  "Beth Ellen",
  "Bevan",
  "Be Vietnam",
  "Bigelow Rules",
  "Bigshot One",
  "Big Shoulders Display",
  "Big Shoulders Text",
  "Bilbo",
  "Bilbo Swash Caps",
  "Biryani",
  "Bitter",
  "Black And White Picture",
  "Black Han Sans",
  "Black Ops One",
  "Blinker",
  "Bonbon",
  "Boogaloo",
  "Bowlby One",
  "Bowlby One SC",
  "Brawler",
  "Bree Serif",
  "Bubblegum Sans",
  "Bubbler One",
  "Buda",
  "Buenard",
  "Bungee",
  "Bungee Hairline",
  "Bungee Inline",
  "Bungee Outline",
  "Bungee Shade",
  "Butcherman",
  "Butterfly Kids",
  "Cabin",
  "Cabin Condensed",
  "Cabin Sketch",
  "Caesar Dressing",
  "Cagliostro",
  "Cairo",
  "Caladea",
  "Calistoga",
  "Cambay",
  "Cambo",
  "Candal",
  "Cantarell",
  "Cantata One",
  "Cantora One",
  "Capriola",
  "Cardo",
  "Carme",
  "Carrois Gothic",
  "Carrois Gothic SC",
  "Carter One",
  "Catamaran",
  "Caudex",
  "Caveat",
  "Caveat Brush",
  "Cedarville Cursive",
  "Ceviche One",
  "Chakra Petch",
  "Changa",
  "Changa One",
  "Chango",
  "Charm",
  "Charmonman",
  "Chathura",
  "Chau Philomene One",
  "Chela One",
  "Chelsea Market",
  "Cherry Swash",
  "Chicle",
  "Chilanka",
  "Chivo",
  "Chonburi",
  "Cinzel",
  "Cinzel Decorative",
  "Clicker Script",
  "Coda",
  "Coda Caption",
  "Codystar",
  "Coiny",
  "Combo",
  "Comfortaa",
  "Comic Neue",
  "Concert One",
  "Condiment",
  "Contrail One",
  "Convergence",
  "Cookie",
  "Copse",
  "Corben",
  "Cormorant",
  "Cormorant Garamond",
  "Cormorant Infant",
  "Cormorant SC",
  "Cormorant Unicase",
  "Cormorant Upright",
  "Courgette",
  "Courier Prime",
  "Coustard",
  "Covered By Your Grace",
  "Creepster",
  "Crete Round",
  "Crimson Pro",
  "Crimson Text",
  "Croissant One",
  "Cuprum",
  "Cute Font",
  "Cutive",
  "Cutive Mono",
  "Damion",
  "Dancing Script",
  "Darker Grotesque",
  "Dawning of a New Day",
  "Days One",
  "Dekko",
  "Delius",
  "Delius Swash Caps",
  "Delius Unicase",
  "Della Respira",
  "Denk One",
  "Devonshire",
  "Dhurjati",
  "Didact Gothic",
  "Diplomata",
  "Diplomata SC",
  "DM Sans",
  "DM Serif Display",
  "DM Serif Text",
  "Do Hyeon",
  "Dokdo",
  "Domine",
  "Donegal One",
  "Doppio One",
  "Dorsa",
  "Dosis",
  "Dr Sugiyama",
  "Duru Sans",
  "Dynalight",
  "Eagle Lake",
  "East Sea Dokdo",
  "Eater",
  "EB Garamond",
  "Economica",
  "Eczar",
  "Electrolize",
  "El Messiri",
  "Elsie",
  "Elsie Swash Caps",
  "Emblema One",
  "Emilys Candy",
  "Encode Sans",
  "Encode Sans Condensed",
  "Encode Sans Expanded",
  "Encode Sans Semi Condensed",
  "Encode Sans Semi Expanded",
  "Engagement",
  "Englebert",
  "Enriqueta",
  "Erica One",
  "Esteban",
  "Euphoria Script",
  "Ewert",
  "Exo",
  "Exo 2",
  "Expletus Sans",
  "Fahkwang",
  "Fanwood Text",
  "Farro",
  "Farsan",
  "Fascinate",
  "Fascinate Inline",
  "Faster One",
  "Fauna One",
  "Faustina",
  "Federant",
  "Federo",
  "Felipa",
  "Fenix",
  "Finger Paint",
  "Fira Code",
  "Fira Mono",
  "Fira Sans",
  "Fira Sans Condensed",
  "Fira Sans Extra Condensed",
  "Fjalla One",
  "Fjord One",
  "Flamenco",
  "Flavors",
  "Fondamento",
  "Forum",
  "Francois One",
  "Frank Ruhl Libre",
  "Freckle Face",
  "Fredericka the Great",
  "Fredoka One",
  "Fresca",
  "Frijole",
  "Fruktur",
  "Fugaz One",
  "Gabriela",
  "Gaegu",
  "Gafata",
  "Galada",
  "Galdeano",
  "Galindo",
  "Gamja Flower",
  "Gayathri",
  "Gelasio",
  "Gentium Basic",
  "Gentium Book Basic",
  "Geo",
  "Geostar",
  "Geostar Fill",
  "Germania One",
  "GFS Didot",
  "GFS Neohellenic",
  "Gidugu",
  "Gilda Display",
  "Girassol",
  "Give You Glory",
  "Glass Antiqua",
  "Glegoo",
  "Gloria Hallelujah",
  "Goblin One",
  "Gochi Hand",
  "Gorditas",
  "Gothic A1",
  "Gotu",
  "Goudy Bookletter 1911",
  "Graduate",
  "Grand Hotel",
  "Gravitas One",
  "Great Vibes",
  "Grenze",
  "Griffy",
  "Gruppo",
  "Gudea",
  "Gugi",
  "Gupter",
  "Gurajada",
  "Habibi",
  "Halant",
  "Hammersmith One",
  "Hanalei",
  "Hanalei Fill",
  "Handlee",
  "Happy Monkey",
  "Harmattan",
  "Headland One",
  "Heebo",
  "Henny Penny",
  "Hepta Slab",
  "Herr Von Muellerhoff",
  "Hi Melody",
  "Hind",
  "Hind Guntur",
  "Hind Madurai",
  "Hind Siliguri",
  "Hind Vadodara",
  "Holtwood One SC",
  "Homenaje",
  "Ibarra Real Nova",
  "IBM Plex Mono",
  "IBM Plex Sans",
  "IBM Plex Sans Condensed",
  "IBM Plex Serif",
  "Iceberg",
  "Iceland",
  "IM Fell Double Pica",
  "IM Fell Double Pica SC",
  "IM Fell DW Pica",
  "IM Fell DW Pica SC",
  "IM Fell English",
  "IM Fell English SC",
  "IM Fell French Canon",
  "IM Fell French Canon SC",
  "IM Fell Great Primer",
  "IM Fell Great Primer SC",
  "Imprima",
  "Inconsolata",
  "Inder",
  "Indie Flower",
  "Inika",
  "Inknut Antiqua",
  "Inria Sans",
  "Inria Serif",
  "Inter",
  "Istok Web",
  "Italiana",
  "Italianno",
  "Itim",
  "Jacques Francois",
  "Jacques Francois Shadow",
  "Jaldi",
  "Jim Nightshade",
  "Jockey One",
  "Jolly Lodger",
  "Jomhuria",
  "Jomolhari",
  "Josefin Sans",
  "Josefin Slab",
  "Joti One",
  "Jua",
  "Judson",
  "Julee",
  "Julius Sans One",
  "Junge",
  "Jura",
  "Just Me Again Down Here",
  "K2D",
  "Kadwa",
  "Kalam",
  "Kameron",
  "Kanit",
  "Kantumruy",
  "Karla",
  "Karma",
  "Katibeh",
  "Kaushan Script",
  "Kavivanar",
  "Kavoon",
  "Kdam Thmor",
  "Keania One",
  "Kelly Slab",
  "Kenia",
  "Khand",
  "Khula",
  "Kirang Haerang",
  "Kite One",
  "Knewave",
  "Kodchasan",
  "KoHo",
  "Kotta One",
  "Kreon",
  "Kristi",
  "Krona One",
  "Krub",
  "Kulim Park",
  "Kumar One",
  "Kurale",
  "La Belle Aurore",
  "Lacquer",
  "Laila",
  "Lakki Reddy",
  "Lalezar",
  "Lancelot",
  "Lateef",
  "Lato",
  "League Script",
  "Leckerli One",
  "Ledger",
  "Lekton",
  "Lemon",
  "Lemonada",
  "Lexend Deca",
  "Lexend Exa",
  "Lexend Giga",
  "Lexend Mega",
  "Lexend Peta",
  "Lexend Tera",
  "Lexend Zetta",
  "Libre Barcode 128",
  "Libre Barcode 128 Text",
  "Libre Barcode 39",
  "Libre Barcode 39 Extended",
  "Libre Barcode 39 Extended Text",
  "Libre Barcode 39 Text",
  "Libre Baskerville",
  "Libre Caslon Display",
  "Libre Caslon Text",
  "Libre Franklin",
  "Life Savers",
  "Lilita One",
  "Lily Script One",
  "Limelight",
  "Linden Hill",
  "Literata",
  "Liu Jian Mao Cao",
  "Livvic",
  "Lobster",
  "Lobster Two",
  "Londrina Outline",
  "Londrina Shadow",
  "Londrina Sketch",
  "Londrina Solid",
  "Long Cang",
  "Lora",
  "Loved by the King",
  "Lovers Quarrel",
  "Love Ya Like A Sister",
  "Lusitana",
  "Lustria",
  "Macondo",
  "Macondo Swash Caps",
  "Mada",
  "Magra",
  "Maitree",
  "Major Mono Display",
  "Mako",
  "Mali",
  "Mallanna",
  "Mandali",
  "Manjari",
  "Manrope",
  "Mansalva",
  "Manuale",
  "Marcellus",
  "Marcellus SC",
  "Marck Script",
  "Margarine",
  "Markazi Text",
  "Marko One",
  "Marmelad",
  "Martel",
  "Martel Sans",
  "Marvel",
  "Ma Shan Zheng",
  "Mate",
  "Mate SC",
  "Maven Pro",
  "McLaren",
  "Meddon",
  "MedievalSharp",
  "Medula One",
  "Meera Inimai",
  "Megrim",
  "Meie Script",
  "Merienda",
  "Merienda One",
  "Merriweather",
  "Merriweather Sans",
  "Metal Mania",
  "Metamorphous",
  "Metrophobic",
  "Michroma",
  "Milonga",
  "Miltonian",
  "Miltonian Tattoo",
  "Mina",
  "Miniver",
  "Miriam Libre",
  "Mirza",
  "Miss Fajardose",
  "Mitr",
  "Modak",
  "Modern Antiqua",
  "Mogra",
  "Molengo",
  "Molle",
  "Monda",
  "Monofett",
  "Monoton",
  "Monsieur La Doulaise",
  "Montaga",
  "Montserrat",
  "Montserrat Alternates",
  "Montserrat Subrayada",
  "Mouse Memoirs",
  "Mr Bedfort",
  "Mr Dafoe",
  "Mr De Haviland",
  "Mrs Saint Delafield",
  "Mrs Sheppards",
  "Mukta",
  "Mukta Mahee",
  "Mukta Malar",
  "Mukta Vaani",
  "Muli",
  "Mystery Quest",
  "Nanum Brush Script",
  "Nanum Gothic",
  "Nanum Gothic Coding",
  "Nanum Myeongjo",
  "Nanum Pen Script",
  "Neucha",
  "Neuton",
  "New Rocker",
  "News Cycle",
  "Niconne",
  "Niramit",
  "Nixie One",
  "Nobile",
  "Norican",
  "Nosifer",
  "Notable",
  "Nothing You Could Do",
  "Noticia Text",
  "Noto Sans",
  "Noto Serif",
  "Nova Cut",
  "Nova Flat",
  "Nova Mono",
  "Nova Oval",
  "Nova Round",
  "Nova Script",
  "Nova Slim",
  "Nova Square",
  "NTR",
  "Numans",
  "Nunito",
  "Nunito Sans",
  "Odibee Sans",
  "Odor Mean Chey",
  "Offside",
  "Oldenburg",
  "Old Standard TT",
  "Oleo Script",
  "Oleo Script Swash Caps",
  "Oranienbaum",
  "Orbitron",
  "Oregano",
  "Orienta",
  "Original Surfer",
  "Oswald",
  "Overlock",
  "Overlock SC",
  "Overpass",
  "Overpass Mono",
  "Over the Rainbow",
  "Ovo",
  "Oxanium",
  "Oxygen",
  "Oxygen Mono",
  "Pacifico",
  "Padauk",
  "Palanquin",
  "Palanquin Dark",
  "Pangolin",
  "Paprika",
  "Parisienne",
  "Passero One",
  "Passion One",
  "Pathway Gothic One",
  "Patrick Hand",
  "Patrick Hand SC",
  "Pattaya",
  "Patua One",
  "Pavanam",
  "Paytone One",
  "Peddana",
  "Peralta",
  "Petit Formal Script",
  "Petrona",
  "Philosopher",
  "Piedra",
  "Pinyon Script",
  "Pirata One",
  "Plaster",
  "Play",
  "Playball",
  "Playfair Display",
  "Playfair Display SC",
  "Podkova",
  "Poiret One",
  "Poller One",
  "Poly",
  "Pontano Sans",
  "Poor Story",
  "Poppins",
  "Port Lligat Sans",
  "Port Lligat Slab",
  "Pragati Narrow",
  "Prata",
  "Press Start 2P",
  "Pridi",
  "Princess Sofia",
  "Prociono",
  "Prompt",
  "Prosto One",
  "Proza Libre",
  "PT Mono",
  "PT Sans",
  "PT Sans Caption",
  "PT Sans Narrow",
  "PT Serif",
  "PT Serif Caption",
  "Public Sans",
  "Puritan",
  "Purple Purse",
  "Quando",
  "Quantico",
  "Quattrocento",
  "Quattrocento Sans",
  "Questrial",
  "Quicksand",
  "Quintessential",
  "Qwigley",
  "Racing Sans One",
  "Radley",
  "Rajdhani",
  "Rakkas",
  "Raleway",
  "Raleway Dots",
  "Ramabhadra",
  "Ramaraja",
  "Rambla",
  "Rammetto One",
  "Ranchers",
  "Ranga",
  "Rasa",
  "Rationale",
  "Ravi Prakash",
  "Red Hat Display",
  "Red Hat Text",
  "Reem Kufi",
  "Reenie Beanie",
  "Revalia",
  "Rhodium Libre",
  "Ribeye",
  "Ribeye Marrow",
  "Righteous",
  "Risque",
  "Roboto",
  "Rokkitt",
  "Romanesco",
  "Ropa Sans",
  "Rosario",
  "Rosarivo",
  "Rouge Script",
  "Rozha One",
  "Rubik",
  "Rubik Mono One",
  "Ruda",
  "Rufina",
  "Ruge Boogie",
  "Ruluko",
  "Rum Raisin",
  "Ruslan Display",
  "Russo One",
  "Ruthie",
  "Rye",
  "Sacramento",
  "Sahitya",
  "Sail",
  "Saira",
  "Saira Condensed",
  "Saira Extra Condensed",
  "Saira Semi Condensed",
  "Saira Stencil One",
  "Salsa",
  "Sanchez",
  "Sancreek",
  "Sansita",
  "Sarabun",
  "Sarala",
  "Sarina",
  "Sarpanch",
  "Scada",
  "Scheherazade",
  "Scope One",
  "Seaweed Script",
  "Secular One",
  "Sedgwick Ave",
  "Sedgwick Ave Display",
  "Sen",
  "Sevillana",
  "Seymour One",
  "Shadows Into Light",
  "Shadows Into Light Two",
  "Shanti",
  "Share",
  "Share Tech",
  "Share Tech Mono",
  "Shojumaru",
  "Short Stack",
  "Shrikhand",
  "Sigmar One",
  "Signika",
  "Signika Negative",
  "Simonetta",
  "Single Day",
  "Sintony",
  "Sirin Stencil",
  "Six Caps",
  "Skranji",
  "Slabo 13px",
  "Slabo 27px",
  "Smythe",
  "Sniglet",
  "Snippet",
  "Snowburst One",
  "Sofadi One",
  "Sofia",
  "Solway",
  "Song Myung",
  "Sonsie One",
  "Sorts Mill Goudy",
  "Source Code Pro",
  "Source Sans Pro",
  "Source Serif Pro",
  "Space Mono",
  "Spartan",
  "Spectral",
  "Spectral SC",
  "Spicy Rice",
  "Spinnaker",
  "Spirax",
  "Squada One",
  "Sree Krushnadevaraya",
  "Sriracha",
  "Srisakdi",
  "Staatliches",
  "Stalemate",
  "Stalinist One",
  "Stardos Stencil",
  "Stint Ultra Condensed",
  "Stint Ultra Expanded",
  "Stoke",
  "Strait",
  "Stylish",
  "Sue Ellen Francisco",
  "Suez One",
  "Sulphur Point",
  "Sumana",
  "Sunflower",
  "Supermercado One",
  "Sura",
  "Suranna",
  "Suravaram",
  "Swanky and Moo Moo",
  "Tajawal",
  "Tangerine",
  "Tauri",
  "Taviraj",
  "Teko",
  "Telex",
  "Tenali Ramakrishna",
  "Tenor Sans",
  "Text Me One",
  "Thasadith",
  "The Girl Next Door",
  "Tienne",
  "Tillana",
  "Timmana",
  "Titan One",
  "Titillium Web",
  "Tomorrow",
  "Trade Winds",
  "Trirong",
  "Trocchi",
  "Trochut",
  "Trykker",
  "Tulpen One",
  "Turret Road",
  "Uncial Antiqua",
  "Underdog",
  "Unica One",
  "UnifrakturCook",
  "UnifrakturMaguntia",
  "Unlock",
  "Unna",
  "Vampiro One",
  "Varela",
  "Vast Shadow",
  "Vesper Libre",
  "Viaoda Libre",
  "Vibes",
  "Vibur",
  "Vidaloka",
  "Viga",
  "Voces",
  "Volkhov",
  "Vollkorn",
  "Vollkorn SC",
  "Voltaire",
  "VT323",
  "Waiting for the Sunrise",
  "Wallpoet",
  "Warnes",
  "Wellfleet",
  "Wendy One",
  "Wire One",
  "Yanone Kaffeesatz",
  "Yantramanav",
  "Yatra One",
  "Yeon Sung",
  "Yeseva One",
  "Yesteryear",
  "Yrsa",
  "ZCOOL KuaiLe",
  "ZCOOL QingKe HuangYou",
  "ZCOOL XiaoWei",
  "Zeyada",
  "Zhi Mang Xing",
  "Zilla Slab",
  "Zilla Slab Highlight"
];
String randomFont() {
  var random = new Random();
  final rand = random.nextInt(fontNames.length);
  return fontNames[rand];
}