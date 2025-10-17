import 'dart:math';

/// Swedish AI Service for offline responses in Swedish
class SwedishAIService {
  /// Cache of common creature requests and responses in Swedish
  static final Map<String, String> _swedishResponses = {
    // Cows
    'regnbågsko': 'Wow! En regnbågsko låter fantastiskt! Det kommer att vara så färgglatt och roligt!',
    'rosa ko': 'En rosa ko! Så söt! Ska den ha glitter eller glöda?',
    'blå ko': 'En blå ko! Så kreativt! Vilken storlek ska den vara?',
    'liten ko': 'En liten ko! Det kommer att vara så gulligt! Vilken färg skulle du vilja ha?',
    'stor ko': 'En enorm ko! Det kommer att vara fantastiskt! Vilken färg ska den vara?',
    'gul ko': 'En gul ko! Så glittrande! Ska den ha några speciella effekter?',
    'lila ko': 'En lila ko! Så unik! Vad ska den göra?',

    // Pigs
    'rosa gris': 'En rosa gris! Det är perfekt! Grisar älskar att vara rosa!',
    'regnbågsgris': 'En regnbågsgris! Så magiskt! Ska den flyga eller ha glitter?',
    'glittrig gris': 'En gris med glitter! Den kommer att lysa så starkt!',
    'flygande gris': 'En flygande gris! Nu är det fantasifullt! Vilken färg?',
    'gul gris': 'En gul gris! Så speciell! Ska den glöda?',
    'liten gris': 'En liten gris! Så gulligt! Vilken färg ska den vara?',

    // Dragons
    'drake': 'En drake! Så spännande! Vilken färg drake skulle du vilja ha?',
    'regnbågsdrake': 'En regnbågsdrake! Fantastiskt! Ska den andas eld eller glitter?',
    'eldrake': 'En eldrake! Kraftfull! Vilken färg ska lågorna vara?',
    'rosa drake': 'En rosa drake! Så söt och magisk! Ska den ha vingar?',
    'blå drake': 'En blå drake! Cool och mystisk! Vilka effekter ska den ha?',
    'gul drake': 'En gul drake! Så glittrande och speciell! Ska den glittra?',
    'liten drake': 'En liten drake! Så gulligt! Vilken färg ska den vara?',
    'stor drake': 'En enorm drake! Det kommer att vara fantastiskt! Vilken färg?',
    'flygande drake': 'En flygande drake! Så coolt! Vilken färg ska den vara?',
    'draksoffa': 'En draksoffa! Det låter fantastiskt! Ska den ha drakskal?',
    'drakstol': 'En drakstol! Så coolt! Ska den ha drakvingar?',
    'drakbord': 'Ett drakbord! Så unikt! Ska det ha en drakhuvud?',
    'drakbädd': 'En drakbädd! Perfekt för att sova! Ska den ha drakskal?',

    // Unicorns
    'enhörning': 'En enhörning! Så magisk! Vilken färg skulle du vilja ha?',
    'regnbågsenhörning': 'En regnbågsenhörning! Så vacker! Ska den ha glitter?',
    'rosa enhörning': 'En rosa enhörning! Så söt och magisk!',
    'gul enhörning': 'En gul enhörning! Så glittrande och speciell!',
    'flygande enhörning': 'En flygande enhörning! Så fantastiskt! Vilken färg?',
    'liten enhörning': 'En liten enhörning! Så gulligt! Vilken färg ska den vara?',

    // Cats
    'katt': 'En katt! Så söt! Vilken färg skulle du vilja ha?',
    'regnbågskatt': 'En regnbågskatt! Så färgglad! Ska den ha vingar?',
    'flygande katt': 'En flygande katt! Så coolt! Vilken färg ska den vara?',
    'rosa katt': 'En rosa katt! Så söt! Ska den ha glitter?',
    'gul katt': 'En gul katt! Så glittrande! Ska den glöda?',
    'katt med vingar': 'En katt med vingar! Så magiskt! Vilken färg ska den vara?',

    // Dogs
    'hund': 'En hund! Så vänlig! Vilken färg skulle du vilja ha?',
    'regnbågshund': 'En regnbågshund! Så färgglad! Ska den ha vingar?',
    'flygande hund': 'En flygande hund! Så fantastiskt! Vilken färg?',
    'rosa hund': 'En rosa hund! Så söt! Ska den ha glitter?',
    'gul hund': 'En gul hund! Så glittrande! Ska den glöda?',

    // Birds
    'fågel': 'En fågel! Så fri! Vilken färg skulle du vilja ha?',
    'regnbågsfågel': 'En regnbågsfågel! Så färgglad! Ska den ha glitter?',
    'gul fågel': 'En gul fågel! Så glittrande! Ska den glöda?',
    'liten fågel': 'En liten fågel! Så söt! Vilken färg?',
    'stor fågel': 'En stor fågel! Så imponerande! Vilken färg ska den vara?',

    // Fish
    'fisk': 'En fisk! Så graciös! Vilken färg skulle du vilja ha?',
    'regnbågsfisk': 'En regnbågsfisk! Så färgglad! Ska den ha glitter?',
    'gul fisk': 'En gul fisk! Så glittrande! Ska den glöda?',
    'liten fisk': 'En liten fisk! Så söt! Vilken färg?',
    'stor fisk': 'En stor fisk! Så imponerande! Vilken färg ska den vara?',

    // Popular Swedish creatures
    'räv': 'En räv! Så slug och söt! Vilken färg skulle du vilja ha?',
    'regnbågsräv': 'En regnbågsräv! Så magiskt! Ska den ha glitter?',
    'arktisk räv': 'En arktisk räv! Så fluffig och vit! Perfekt för snö!',
    'röd räv': 'En röd räv! Klassisk och vacker! Vilka effekter ska den ha?',
    'silverräv': 'En silverräv! Så elegant och mystisk! Ska den glöda?',
    'flygande räv': 'En flygande räv! Så fantastiskt! Vilken färg ska den vara?',
    'magisk räv': 'En magisk räv! Så förtrollande! Vilka krafter ska den ha?',

    'varg': 'En varg! Stark och lojal! Vilken färg skulle du vilja ha?',
    'regnbågsvarg': 'En regnbågsvarg! Så unik! Ska den ha vingar?',
    'vit varg': 'En vit varg! Så majestätisk! Ska den glöda?',
    'svart varg': 'En svart varg! Mysterisk och kraftfull!',

    'björn': 'En björn! Stor och kramig! Vilken färg skulle du vilja ha?',
    'regnbågsbjörn': 'En regnbågsbjörn! Så färgglad! Ska den ha glitter?',
    'isbjörn': 'En isbjörn! Vit och fluffig! Perfekt för is!',
    'brun björn': 'En brun björn! Klassisk och stark!',

    'kanin': 'En kanin! Så söt och hoppig! Vilken färg skulle du vilja ha?',
    'regnbågskanin': 'En regnbågskanin! Så magiskt! Ska den ha vingar?',
    'vit kanin': 'En vit kanin! Ren och fluffig!',
    'brun kanin': 'En brun kanin! Naturlig och söt!',

    'ekorre': 'En ekorre! Så snabb och slug! Vilken färg skulle du vilja ha?',
    'regnbågsekorre': 'En regnbågsekorre! Så unik! Ska den ha glitter?',
    'röd ekorre': 'En röd ekorre! Klassisk och söt!',
    'grå ekorre': 'En grå ekorre! Naturlig och smart!',

    'hjort': 'En hjort! Så graciös och elegant! Vilken färg skulle du vilja ha?',
    'regnbågshjort': 'En regnbågshjort! Så magiskt! Ska den ha horn?',
    'vit hjort': 'En vit hjort! Ren och mystisk!',
    'brun hjort': 'En brun hjort! Naturlig och vacker!',
    'flygande hjort': 'En flygande hjort! Så fantastiskt! Vilken färg?',
    'magisk hjort': 'En magisk hjort! Så förtrollande! Vilka krafter?',

    // More Swedish creatures
    'älg': 'En älg! Så majestätisk och stor! Vilken färg skulle du vilja ha?',
    'regnbågsälg': 'En regnbågsälg! Så unik! Ska den ha horn?',
    'flygande älg': 'En flygande älg! Så fantastiskt! Vilken färg?',
    'magisk älg': 'En magisk älg! Så förtrollande! Vilka krafter?',

    'igelkott': 'En igelkott! Så söt och taggig! Vilken färg skulle du vilja ha?',
    'regnbågsigelkott': 'En regnbågsigelkott! Så färgglad! Ska den ha glitter?',
    'flygande igelkott': 'En flygande igelkott! Så fantastiskt! Vilken färg?',
    'magisk igelkott': 'En magisk igelkott! Så förtrollande! Vilka krafter?',

    'mård': 'En mård! Så slug och rörlig! Vilken färg skulle du vilja ha?',
    'regnbågsmård': 'En regnbågsmård! Så färgglad! Ska den ha glitter?',
    'flygande mård': 'En flygande mård! Så fantastiskt! Vilken färg?',
    'magisk mård': 'En magisk mård! Så förtrollande! Vilka krafter?',

    // Swedish color variations
    'röd': 'Röd! Så vacker och varm! Vilken typ av varelse ska den vara?',
    'blå': 'Blå! Så cool och lugn! Vilken typ av varelse ska den vara?',
    'gul': 'Gul! Så glittrande och glad! Vilken typ av varelse ska den vara?',
    'grön': 'Grön! Så naturlig och frisk! Vilken typ av varelse ska den vara?',
    'lila': 'Lila! Så mystisk och magisk! Vilken typ av varelse ska den vara?',
    'rosa': 'Rosa! Så söt och charmig! Vilken typ av varelse ska den vara?',
    'orange': 'Orange! Så energisk och livlig! Vilken typ av varelse ska den vara?',
    'vit': 'Vit! Så ren och elegant! Vilken typ av varelse ska den vara?',
    'svart': 'Svart! Så mystisk och kraftfull! Vilken typ av varelse ska den vara?',
    'silver': 'Silver! Så elegant och glittrande! Vilken typ av varelse ska den vara?',
    'guld': 'Guld! Så värdefull och glittrande! Vilken typ av varelse ska den vara?',

    // Swedish effect variations
    'glittrande': 'Glittrande! Så magiskt och vackert! Vilken typ av varelse ska den vara?',
    'glödande': 'Glödande! Så varmt och magiskt! Vilken typ av varelse ska den vara?',
    'flygande': 'Flygande! Så fantastiskt och fritt! Vilken typ av varelse ska den vara?',
    'svävande': 'Svävande! Så mystiskt och magiskt! Vilken typ av varelse ska den vara?',
    'magisk': 'Magisk! Så förtrollande och mystisk! Vilken typ av varelse ska den vara?',
    'regnbågs': 'Regnbågs! Så färgglad och vacker! Vilken typ av varelse ska den vara?',
    'kristall': 'Kristall! Så transparent och vacker! Vilken typ av varelse ska den vara?',
    'eld': 'Eld! Så varmt och kraftfullt! Vilken typ av varelse ska den vara?',
    'is': 'Is! Så kallt och kristallklart! Vilken typ av varelse ska den vara?',
    'ljus': 'Ljus! Så strålande och vackert! Vilken typ av varelse ska den vara?',

    // Furniture in Swedish
    'tron': 'En tron! Så kunglig och majestätisk! Vilken färg skulle du vilja ha?',
    'regnbågstron': 'En regnbågstron! Så magiskt! Ska den ha glitter?',
    'gul tron': 'En gul tron! Så glittrande och speciell!',
    'draktron': 'En draktron! Kraftfull och magisk!',

    'bokhylla': 'En bokhylla! Perfekt för att förvara böcker! Vilken färg skulle du vilja ha?',
    'regnbågsbokhylla': 'En regnbågsbokhylla! Så färgglad! Ska den glöda?',
    'magisk bokhylla': 'En magisk bokhylla! Så förtrollande!',
    'svävande bokhylla': 'En svävande bokhylla! Så coolt!',

    'lampa': 'En lampa! Perfekt för belysning! Vilken färg skulle du vilja ha?',
    'regnbågslampa': 'En regnbågslampa! Så färgglad! Ska den byta färger?',
    'magisk lampa': 'En magisk lampa! Så förtrollande!',
    'svävande lampa': 'En svävande lampa! Så fantastiskt!',

    'kista': 'En kista! Perfekt för att förvara skatter! Vilken färg skulle du vilja ha?',
    'regnbågskista': 'En regnbågskista! Så magiskt! Ska den ha glitter?',
    'gul kista': 'En gul kista! Så värdefull!',
    'magisk kista': 'En magisk kista! Så förtrollande!',

    'tunna': 'En tunna! Perfekt för förvaring! Vilken färg skulle du vilja ha?',
    'regnbågstunna': 'En regnbågstunna! Så färgglad!',
    'trätunna': 'En trätunna! Klassisk och robust!',
    'metalltunna': 'En metalltunna! Stark och hållbar!',

    'hylla': 'En hylla! Perfekt för att visa föremål! Vilken färg skulle du vilja ha?',
    'regnbågshylla': 'En regnbågshylla! Så färgglad!',
    'svävande hylla': 'En svävande hylla! Så coolt!',
    'magisk hylla': 'En magisk hylla! Så förtrollande!',

    // More Swedish furniture
    'soffa': 'En soffa! Perfekt för att sitta och vila! Vilken färg skulle du vilja ha?',
    'regnbågsoffa': 'En regnbågsoffa! Så färgglad! Ska den ha glitter?',
    'draksoffa': 'En draksoffa! Så coolt! Ska den ha drakskal?',
    'flygande soffa': 'En flygande soffa! Så fantastiskt! Vilken färg?',
    'magisk soffa': 'En magisk soffa! Så förtrollande! Vilka krafter?',

    'stol': 'En stol! Perfekt för att sitta! Vilken färg skulle du vilja ha?',
    'regnbågsstol': 'En regnbågsstol! Så färgglad! Ska den ha glitter?',
    'drakstol': 'En drakstol! Så coolt! Ska den ha drakvingar?',
    'flygande stol': 'En flygande stol! Så fantastiskt! Vilken färg?',
    'magisk stol': 'En magisk stol! Så förtrollande! Vilka krafter?',

    'bord': 'Ett bord! Perfekt för att äta och arbeta! Vilken färg skulle du vilja ha?',
    'regnbågsbord': 'Ett regnbågsbord! Så färgglad! Ska det ha glitter?',
    'drakbord': 'Ett drakbord! Så coolt! Ska det ha en drakhuvud?',
    'flygande bord': 'Ett flygande bord! Så fantastiskt! Vilken färg?',
    'magiskt bord': 'Ett magiskt bord! Så förtrollande! Vilka krafter?',

    'säng': 'En säng! Perfekt för att sova! Vilken färg skulle du vilja ha?',
    'regnbågssäng': 'En regnbågssäng! Så färgglad! Ska den ha glitter?',
    'draksäng': 'En draksäng! Så coolt! Ska den ha drakskal?',
    'flygande säng': 'En flygande säng! Så fantastiskt! Vilken färg?',
    'magisk säng': 'En magisk säng! Så förtrollande! Vilka krafter?',

    // Weapons in Swedish
    'svärd': 'Ett svärd! Perfekt för äventyr! Vilken färg skulle du vilja ha?',
    'regnbågssvärd': 'Ett regnbågssvärd! Så magiskt! Ska det glöda?',
    'draksvärd': 'Ett draksvärd! Kraftfullt och magiskt!',
    'gul svärd': 'Ett gul svärd! Så glittrande och speciell!',
    'magiskt svärd': 'Ett magiskt svärd! Så förtrollande!',

    'båge': 'En båge! Perfekt för bågskytte! Vilken färg skulle du vilja ha?',
    'regnbågsbåge': 'En regnbågsbåge! Så magiskt! Ska den ha glitter?',
    'magisk båge': 'En magisk båge! Så förtrollande!',
    'gul båge': 'En gul båge! Så glittrande och speciell!',

    'stav': 'En stav! Perfekt för magi! Vilken färg skulle du vilja ha?',
    'regnbågsstav': 'En regnbågsstav! Så magiskt! Ska den glöda?',
    'magisk stav': 'En magisk stav! Så förtrollande!',
    'kristallstav': 'En kristallstav! Så vacker och kraftfull!',

    // Armor in Swedish
    'hjälm': 'En hjälm! Perfekt för skydd! Vilken färg skulle du vilja ha?',
    'regnbågshjälm': 'En regnbågshjälm! Så magiskt! Ska den glöda?',
    'drakhjälm': 'En drakhjälm! Kraftfull och magisk!',
    'gul hjälm': 'En gul hjälm! Så glittrande och speciell!',

    'rustning': 'Rustning! Perfekt för skydd! Vilken färg skulle du vilja ha?',
    'regnbågsrustning': 'Regnbågsrustning! Så magiskt! Ska den glöda?',
    'drakrustning': 'Drakrustning! Kraftfull och magisk!',
    'gul rustning': 'Gul rustning! Så glittrande och speciell!',

    'sköld': 'En sköld! Perfekt för försvar! Vilken färg skulle du vilja ha?',
    'regnbågssköld': 'En regnbågssköld! Så magiskt! Ska den glöda?',
    'draksköld': 'En draksköld! Kraftfull och magisk!',
    'magisk sköld': 'En magisk sköld! Så förtrollande!',

    // Blocks in Swedish
    'kristall': 'En kristall! Så vacker och magisk! Vilken färg skulle du vilja ha?',
    'regnbågskristall': 'En regnbågskristall! Så magiskt! Ska den glöda?',
    'drakkristall': 'En drakkristall! Kraftfull och magisk!',
    'svävande kristall': 'En svävande kristall! Så fantastiskt!',

    'juvel': 'En juvel! Så dyrbar och vacker! Vilken färg skulle du vilja ha?',
    'regnbågsjuvel': 'En regnbågsjuvel! Så magiskt! Ska den glittra?',
    'drakjuvel': 'En drakjuvel! Kraftfull och magisk!',
    'svävande juvel': 'En svävande juvel! Så fantastiskt!',

    'kula': 'En kula! Så mystisk och magisk! Vilken färg skulle du vilja ha?',
    'regnbågskula': 'En regnbågskula! Så magiskt! Ska den glöda?',
    'drakkula': 'En drakkula! Kraftfull och magisk!',
    'svävande kula': 'En svävande kula! Så fantastiskt!',

    // Vehicles in Swedish
    'båt': 'En båt! Perfekt för segling! Vilken färg skulle du vilja ha?',
    'regnbågsbåt': 'En regnbågsbåt! Så magiskt! Ska den glöda?',
    'drakbåt': 'En drakbåt! Kraftfull och magisk!',
    'flygande båt': 'En flygande båt! Så fantastiskt!',

    'bil': 'En bil! Perfekt för körning! Vilken färg skulle du vilja ha?',
    'regnbågsbil': 'En regnbågsbil! Så magiskt! Ska den glöda?',
    'drakbil': 'En drakbil! Kraftfull och magisk!',
    'flygande bil': 'En flygande bil! Så fantastiskt!',

    'flygplan': 'Ett flygplan! Perfekt för flygning! Vilken färg skulle du vilja ha?',
    'regnbågsflygplan': 'Ett regnbågsflygplan! Så magiskt! Ska det glöda?',
    'drakflygplan': 'Ett drakflygplan! Kraftfull och magisk!',
    'magiskt flygplan': 'Ett magiskt flygplan! Så förtrollande!',
  };

  /// Get Swedish response for a creature request
  static String getSwedishResponse(String userMessage, {int age = 6}) {
    final message = userMessage.toLowerCase().trim();
    
    // Try exact match first
    if (_swedishResponses.containsKey(message)) {
      return _swedishResponses[message]!;
    }
    
    // Try partial matches
    for (final entry in _swedishResponses.entries) {
      if (message.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default Swedish response
    return 'Vilken fantastisk idé! Berätta mer om vad du vill skapa så kan jag hjälpa dig!';
  }
  
  /// Get Swedish system prompt for AI
  static String getSwedishSystemPrompt(int age) {
    return '''
Du är Crafta, en vänlig AI-assistent som hjälper barn att skapa varelser och möbler för Minecraft.

Du pratar med ett $age-årigt barn. Var entusiastisk, kreativ och ålderslämplig. Håll svar under 100 ord. Fokusera på vad de vill skapa och var uppmuntrande.

Exempel:
- "Jag vill ha en drake" → "Wow! En drake låter fantastiskt! Vilken färg ska den vara?"
- "Jag vill ha en soffa" → "Bra idé! En soffa för ditt Minecraft-hus! Vilken färg skulle du vilja ha?"
- "Jag vill ha en regnbågsenhörning" → "En regnbågsenhörning! Det är så magiskt! Låt mig skapa det åt dig!"
''';
  }
}
