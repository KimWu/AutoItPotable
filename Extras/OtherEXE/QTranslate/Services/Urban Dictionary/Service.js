function serviceHeader(){return new ServiceHeader(24,"Urban Dictionary",'<a href="http://www.urbandictionary.com/">http://www.urbandictionary.com/</a>'+Const.NL+"\u00a91999-2014 Urban Dictionary \u00ae",Capability.DICTIONARY)}function serviceHost(b,a,c){return"www.urbandictionary.com"}function serviceLink(b,a,c){return"http://www.urbandictionary.com/define.php?term="+encodeGetParam(b)}
SupportedLanguages=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];function serviceDictionaryRequest(b,a,c){b="/define.php?term="+encodeGetParam(b);return new RequestData(HttpMethod.GET,b)}
function serviceDictionaryResponse(b,a,c,d){var e=serviceHost(Capability.DICTIONARY,c,d);if(a=midString(a,"\x3c!-- google_ad_section_start --\x3e","\x3c!-- google_ad_section_end --\x3e",!1))a=removeAttributes("<div>"+a,["id","name","class","onclick"]),a=removeElements(a,["table","script","iframe"]),a=updateHtmlLinks(a,e);b=format("http://{0}/{1}",e,encodeGetParam(b));return new ResponseData(a,c,d,b)};
