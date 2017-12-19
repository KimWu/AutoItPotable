#Include <APIConstants.au3>
#Include <GDIPlus.au3>
#Include <Memory.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hBitmap, $hObj, $hImage, $pStream, $bData, $hData, $pData, $tData, $Width, $Height, $Lenght

; 创建位图 (MSDNLogo.png)
$bData = _Image_MSDNLogo()
$Lenght = BinaryLen($bData)
$hData = _MemGlobalAlloc($Lenght, $GMEM_MOVEABLE)
$pData = _MemGlobalLock($hData)
$tData = DllStructCreate('byte[' & $Lenght & ']', $pData)
DllStructSetData($tData, 1, $bData)
_MemGlobalUnlock($hData)
$pStream = _WinAPI_CreateStreamOnHGlobal($hData)
_GDIPlus_Startup()
$hImage = _GDIPlus_BitmapCreateFromStream($pStream)
$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
$Width = _GDIPlus_ImageGetWidth($hImage)
$Height = _GDIPlus_ImageGetHeight($hImage)
_WinAPI_ReleaseStream($pStream)
_GDIPlus_ImageDispose($hImage)
_GDIPlus_Shutdown()

; 创建 GUI
$hForm = GUICreate('MyGUI', $Width, $Height)
$Pic = GUICtrlCreatePic('', 0 , 0, $Width, $Height)
$hPic = GUICtrlGetHandle($Pic)

; 设置位图到控件
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3

Func _GDIPlus_BitmapCreateFromStream($pStream)

	Local $Ret = DllCall($ghGDIPDll, 'uint', 'GdipCreateBitmapFromStream', 'ptr', $pStream, 'ptr*', 0)

	If (@error) Or ($Ret[0]) Then
		Return SetError(@error, @extended, 0)
	EndIf
	Return $Ret[2]
EndFunc   ;==>_GDIPlus_BitmapCreateFromStream

Func _Image_MSDNLogo()

	Local $bImage = _
		 '0x89504E470D0A1A0A0000000D49484452000000BE000000460802000000FDD7B9' & _
		   'BE000000097048597300000B1300000B1301009A9C180000000467414D410000' & _
		   'B18E7CFB5193000000206348524D00007A25000080830000F9FF000080E90000' & _
		   '75300000EA6000003A980000176F925FC546000014444944415478DAEC5D795C' & _
		   '545796BE6FABBDA028A0100B011111177430B82088C10D4D2409C6AD21064D8C' & _
		   '11C1D89A31C14E3A6A667E331AED98C42191884D121BD456034651B15DB22806' & _
		   'C2A68080C5BED7BE507BBD65FE28BBAC201465679C60F2BE3FF855BD77EE79EF' & _
		   'DCF3D53DE79E7BDF03A2280AD0A0F1E880E92EA0415387064D1D1A347568D0D4' & _
		   'A14183A60E0D9A3A3468EAD0A0A94383A60E0D1A3475683C2EA0BF317B6EB6A9' & _
		   '4E54774B65FA17C7F9AC5E309E76304D1DB770BE41F6D97549FD1589A2457D85' & _
		   '243DF73DBB644938ED633A600D83920EF5E73F34579EAAE9AD9552246903D0B1' & _
		   'BC4ADAC13475864197CEFC79597BCD85066D5F3FC6C620088220D0D2AA321AAD' & _
		   'B48F69EA0C099CA4FE56D353F36D8BAA43CBE23321040200008A62333104A6E7' & _
		   '0174AE33347EEAD57E5FD1D555276372192441020008880406EBF810219385D2' & _
		   '3EA6A933386C24552C51B455F40008200C04B24100000A8680C1161F1F4A3B98' & _
		   'A6CE9068521B2B6AFB74723DC6C6289C0214051004E82C61A33D963D37897630' & _
		   '4D9D2151A730485BD5100223084C0002C01865B52132FDEECF57F2784CDAC174' & _
		   '9A3C24DA55867EA51165621002232C148228BC45B57DD39CC54B26D0DEA5471D' & _
		   '57F0E3320186A06C9424489BDC40352BDECD88F9E39BF37EF39EC371BCA3A383' & _
		   'A2288220B85CAE582CA6A9E32E280020009E19E7739A246FB7A980D61C335194' & _
		   'B1EB0F31B1637F0F3FFA9E9E9ED8D8589BCD86E3785C5CDCD9B36769EA0C0F13' & _
		   '4E16B42B5BEB659BE78C150A39F99FBCD0D2ACE47BB08282BD7E3FF18224C9BE' & _
		   'BE3EFB63746AB59A0E586EF1E6AF777B2F977534DFEC88429084A5E11C2E63CA' & _
		   '54FFDF5BAA014110866156AB150080A2284D9D614050D44989FC724947478B12' & _
		   '97EB7D7D7974BA4ACFB0DC4271A7FA625967678B0AA6C0243E33629ABF8352BD' & _
		   '46ABCC64A33D4A8F3A83E08ED25050D9DD764F817118DA5B6D193BE661180200' & _
		   '68549B8A5AE4D51285CD4AAC08F57971CE58DAAF34751E406DC1CFDC9536D5CB' & _
		   '3136AAAAECDEF0F4B8F90BC30000D77AB4272ABBEE55F52ABAB50441D5144BC4' & _
		   '303C7B7610ED5A3A600100004581ABDD9A5A89C26A2514B7DA574EF4FDF79DF3' & _
		   '0100FFE8D1E4DE6CABBED1A6ECEB47300463222486DC2C69A3FD4A8F3AF7A1B4' & _
		   'D8AED5F5B59775723BD57B92A7AF4E990E00A85419F27FEC68ACECC17192C1C6' & _
		   '4882A400003849118FF0DA17994CD6D5D565341A4522516060208BC51A4A52AF' & _
		   'D7777676AA542A168B251289020202200872F32A2A95AAB7B757AD56B3582CA1' & _
		   '5028168B994CB71649D46A756F6FAF46A3613018229168F4E8D1BF703265B158' & _
		   'DADBDB150A058220762B300CFBCD52C764C59938196D22626382973CB354E8CD' & _
		   '010028ADF889DB3D929A3E92245114254912A660804256B53124583840435656' & _
		   '5643430382203C1E6FDBB66DDEDEDE0080C2C2C29C9C9CEAEA6AB55A6DB55A79' & _
		   '3C5E7070F0EAD5ABD3D2D23C3D3D9D9B5754541C3972E4DAB56B3299CC683462' & _
		   '18C6E3F1C2C3C35352525253535D908024C9C2C2C22FBFFCF2F6EDDB1A8DC660' & _
		   '306018C6E170FCFDFDE7CC99B36EDDBAE8E8E8411B5AADD6828282E3C78F5757' & _
		   '576B341AA3D188A2288FC70B090959B56AD5BA75EB8442A18B1ECBCBCBBB75EB' & _
		   '168AA2300C6FDEBC393434140070EFDEBD9C9C9C4B972E757575E9F57A0441B8' & _
		   '5C6E7070F08A152B5E7FFD752FAF472F895123185682BCAED4BFB1F7AAD58A0F' & _
		   '38F575B3FCD9433FCCC82C9AF5EEC5199917A2DE2E8A7AABE8A91DE7A7CE3924' & _
		   '93F50F108E8A8AB21BCB6030BABABA341A4D7272F2501D3263C68CE6E66647DB' & _
		   'BD7BF772B9DCA184172E5C28954A07BDF9E6E6E6848404173DBF68D12292241F' & _
		   '6E585E5E1E1B1BEBA2E1942953AAAAAAE4723983C1B01F898F8F77D6B062C50A' & _
		   '87F0B56BD7288ACACACAF2F5F51D4A616464647D7DFDA37A67E4E63A3A1B51D0' & _
		   'AD39F459C9384F1682C02D466B69BFB9B5570700D0D8881FEEC9350A038385C2' & _
		   '300421108440301BD3DDED5BFBDCE4878B3D0EDF7B7B7BF7F7F7A7A4A4E4E7E7' & _
		   'DB8FB058AC0121E0A79F7E7AF1C517552A1500203333333333D3603038841104' & _
		   '7116BE72E54A6A6AAAD96C1E70C5B6B6B665CB961517173F482A6198CD663B5F' & _
		   '0B1E6C07E3D9B3671312126EDCB8E17C10C330E7485A5B5B9B9898F8E38F3FB2' & _
		   'D9EC41BBCE71DC3EB41C3C78303D3D5D2E970F654555555552529242A1B00F25' & _
		   '4F76C0925AF033CDF2D3FF73333E50189F38E9B454FB5D7997CE68436BA547DF' & _
		   '4F505BF1EEDE7E18822018021400280C30485B279DC644D3B7B8FABDC230BC73' & _
		   'E7CEA2A22200C0CB2FBFBC6AD5AAF1E3C76BB5DACACACA23478E545454D8C5AA' & _
		   'ABABB3B2B2222222F6EDDB67EFEB575E7925292969CC98314AA5B2BCBCFCC891' & _
		   '23B5B5B576E14B972EE5E7E7BFF2CA2B0FEA9604B17DFBF6FAFA7AFB575F5FDF' & _
		   '8C8C8CF8F8783F3F3FB55A2D91488A8B8B0B0A0A1C8C74A0B4B434353555ABD5' & _
		   '3A18B37CF9F2C4C4C4F0F0703E9FDFDDDD7DE3C68DBCBCBCC6C6C6AEAEAEF4F4' & _
		   '748BC5E2BA1B391CCEA953A70E1D3A0400080C0C5CBF7EFDBC79F3FCFDFD351A' & _
		   '4D5959594E4E4E4D4D8D5DB2A1A161D7AE5D595959EE2770232E60111455AF37' & _
		   'BF79AA6AE9DABF9DBDDC58DCAECCFCBE69E5915BCF7CFC7DE26737E7BE906BB1' & _
		   'E25A9C78F544E58203D717FCE5DBF8FDD76377158727FE75F5CAAF140AFDA03A' & _
		   'E7CD9B37A0438F1F3F3E4046ABD53A8FF3BEBEBE2291080020140A2F5EBC3840' & _
		   '582A95C6C4C43884636262CC66B3E36C6969A9637419356A547979F9C3B7545D' & _
		   '5D7DF8F061E756FDFDFD4F3DF59443E7D8B163AF5EBDFA7043994CB671E3C601' & _
		   '4E1C10B0D6AE5DEB1875EC77327FFEFCD6D6D687AD58BA74A943894020904824' & _
		   'EE7B6AC451A7B947BB75F7A58F3FFEAE43D67F5EA64B3B5BF3C2673792B24B56' & _
		   '7EF553DC1F0BF7FEF7FDDE3C75AE6EF6CBF991A9C7A7241E9DB3E0F04707BE33' & _
		   '9B6C43E91C409D03070E0C2A2697CBC78C19E32C8920C8C9932707152E2D2D75' & _
		   '04113E9FDFD8D8E838F5D1471F3934BCF9E69B2E8C75CE750E1E3CE868E5E7E7' & _
		   '575D5DEDA2E1FAF5EBDDA18E83D92A956A503D3D3D3DCEBB353EFDF4D327923A' & _
		   '2449A9ADB85461C0091227C86F64DA8D5FDF5EF36559727EC5EAAFCA62D3CFA4' & _
		   '677C6D363FE047437D5FD13775653FB66B3426D79A9DA93375EA54936948F9B7' & _
		   'DE7ACBB9D357AE5CE9C2EBCE034F6161A1E3D4EEDDBB1DC7F7EDDBE78EED0683' & _
		   '61F2E4C98E56D9D9D9AEE5150A454848883BD4E170386565652E546DDDBAD521' & _
		   '9C9A9AFA84A5C9668294F49B2FF46A8ED4F49C3A5B8BC090CC682DFEBEB55F6B' & _
		   '26F45659558FB4F0EE9AF1A2439FBCC0643E48CE2684FB3D933869C6AC404F4F' & _
		   '96FBD74A49497151BC71261982201B366C184A128220C7C40D00D0D9D9E9F8EC' & _
		   '98F800002412893B77555A5A5A575767FF1C1111F1D24B2FB996F7F6F65EBD7A' & _
		   'B53B9A172E5C3863C60C1702CE314B2A953E31D5640341D6E9CC855DEABCAAEE' & _
		   'DCBCCAA25D97674F1B0500F066A2A3250A9F3B7DA1DDBAD722C5F98792D2B7C6' & _
		   '3E420637041004898C8C7421E0EFEFEF989E88C5E2E9D3A7BB101E3FFEC133ED' & _
		   '36DB8395D7F0F0074F2B9F3C79D29D4D58D7AF5F777C4E4C4CE47038C336898B' & _
		   '8B73C7E4458B16B916080A0A7298AC56AB874DBD7FFD19164152A5ADCA1F9A15' & _
		   '8D0DF2F63BBD817C6C636244FCB6A73114262880A1C89F32173CDCCA8893BD26' & _
		   'ABDC64B3E00403412608D842E62398C0E7F383825C2D6F0904022E976B329900' & _
		   '002291482010B89EBF380F42CE4E0D0E0E6E6B6B0300F4F7F7AF59B3E68D37DE' & _
		   'C8C8C818904839C3315F0300CC9E3DDB1D5BC4623182200441B8160B0E0E1E76' & _
		   '16C6E7F3ED261B0C06B3D9EC66A5FB57A00E050049513849B1703250639E14EC' & _
		   '353B399227E0A86D44838DE85318543A1382C0C1BEDC081E8B09DF7789D64654' & _
		   '2AF477FA746D52BD4E67B15A7192046383BCD68FF71937DAD3DD1F0A8A3A4793' & _
		   '87C164321D857904415C173948921C2A9AECDEBD7BDDBA75F7C3B1D9FCC1071F' & _
		   'E4E5E5252727A7A4A44C9B366D80BCCD66EBE9E971145D020202DCB1C5D3D373' & _
		   '58EA4010C4E3F186A58E402090C9647679F787F6FF0FEAE8F4568AC75099AC7A' & _
		   '9232E2A48D20CD048931502F7FFEAAF1D3101852E0C4E55E6D5D9746A3B798AD' & _
		   '044E902449F105EC4A8D65E30B530000DD66DBB926796DAB4AAD36D96CF7E725' & _
		   '044ED6DD931F2A69FBF0EDF930EC96C1F7A706EE09FC927F81909A9AAAD7EB33' & _
		   '3333F57ABDFD487777F7FEFDFB3FFDF4D3E5CB97EFD8B1232222C27975CC5E81' & _
		   'B48F8B0396415CDCEAFFA1D8085AC32208D264B2DA6C388A221DDDBAEBA51D1D' & _
		   '9D1A03003A234E10008108AB8DF443E0FFF8D30281805DD1AA2E95696D568282' & _
		   '20048351060261B04167B971A961E30B538C0479AE595E794F6E32E1080A4330' & _
		   '441214499208020114E96AD7E038C9602023ADAA999E9E1E1515B567CF9E8B17' & _
		   '2F3EC8ED0C8663C78E9D3F7FFEFDF7DFCFC8C8708C5E388E3B8A96B07BCFC9FF' & _
		   'F2CC6FA45047ADD6575634DFABE9ECBE27D549F5FA3E3DA1348FF1F45C90111B' & _
		   'FFF26C9190D5D3229F302980EDC1C271B2A345EA2DE47BFADC1F4B056AA3EC7A' & _
		   '0B1A24E078712840990D36458B12342AFEBC2D0E00A0C289A66E1D8E934C2642' & _
		   '92144190100010805116A2EDD04CF6628F40DED8316BD6AC0B172E1417171F3D' & _
		   '7AB4A8A8C868343AB2D12D5BB6180C86B7DF7E7B0009088218367DB91FC1B55A' & _
		   '37254716754892B2D9702613B37FCE3A78AEE4B35B5E2D5601CC64234818C614' & _
		   '84787926050922FD5A14EA9796EE6BF8B17BB138F0BD928CBADB6DD9FB2FF497' & _
		   '48F71765807F5267D6CCC09060E18D9BAD77EB6426934DC444132346C76D996B' & _
		   '7F7C93450118062C0E46D80800410040304A4128D2DFA3EBFFB6E58D9C95237C' & _
		   'E53F2121212121A1BCBCFCC30F3F3C7EFCB8E3F87BEFBD171717171D1DCDE170' & _
		   'BCBCBC5A5B5B01001A8D46A9548E1B376E58B50A85E2C9A00E4551F7EEF55455' & _
		   '34D757B4A95A55B8C28CAB2DC251FCF403AB4685FB816F7BFE60F2634C667984' & _
		   '09BDA303B8B1626C0CFF74DE0F477715689BF44C80AE9916FA5CCEF3D99F17E7' & _
		   'EEBEEC65C6D2926385E3BD9DF5FB8A7849491149835DDA878505F51A7E2208BE' & _
		   '3F1F0080E3A44161ECAE6AE77468B20F3E375AEC099E04444545E5E7E7272525' & _
		   'A5A5A529954A0080D56ACDCDCD8D8E8E66B1587E7E7E76311CC72512C9CC9933' & _
		   '8755D8D8D838D20396566B3C73EAE63F4E95E94BFAC406D41F7082010A288885' & _
		   'C0A3BBACFC4E23631A96767A03A1B3C03C06C6C600001D1DF2D796EE173510DE' & _
		   '001233B86B5E9D1BB97BDEDE0305973EB82580B0E7674F58F6E13330FA0825A5' & _
		   'B494E99C2FCBBFBDD0A8B391B8DEE2CD405F7D3A64F9DE65AC27ED1D282B57AE' & _
		   '944AA55BB66CB17FADACACA4280A82A0C993273B52A24B972EA5A4A40CABCA79' & _
		   '597E2452E7DCD9D24FDE3B2DAC314F05023EF021012001C540212F1612FA9478' & _
		   'E25B733D9686020050268AFAA2562BAEEF37F1F8ECA6FAEED94AAE603473C2FC' & _
		   'D0A9EBA6FBC6059D3CF6DDD5FD25013067E9D3E1295FACE2F8701EE92E61185A' & _
		   'BF7EC65AFC298DDA8420909790039E582C5BB6EC9D77DED1E97400009D4E67B1' & _
		   '58582CD682050B0E1C386017F8E69B6FEEDEBD3B6992ABD774DCBA756BA45367' & _
		   '6F4ACE6283C80BE251304011E0C9407CBC39E2B981E2E5933D168D43780C0040' & _
		   '4343D7E5F3154D375A8CB54A968E5AB831FAF9F79F8DBD1B0E28C010DC2FF9FB' & _
		   '8F12AE7B76C6B498D0E99B6731788C7FF15E51D8C7973BF2C9A1D56A5D4CB0CD' & _
		   '66B32347E1F3F9F6FADBDCB973C3C3C31B1A1AEC7CCACCCC3C73E6CC505B3F35' & _
		   '1ACD8E1D3BEC45BC914B9DFD6B96A0DFF79820922FE67B86F9784407F26605B0' & _
		   'C37DEC675B5BA51FFEE719F9D74DA15A6608C442008302805DDC43FD996078B2' & _
		   '00000683F9DAD53B9E38323B21226E5104F87D60CF9E3D288A6666660EBA0DF4' & _
		   '8B2FBE70ECD499356B967D7AC5E572D3D2D21C2B91E7CE9D7BFDF5D70F1E3CF8' & _
		   '30053B3A3A366EDC78F3E64DFB1C7EA8B2E4AF4F9DE8C34978AF9E82002A60C1' & _
		   '3F1F2D24929E2D4BFF32B385311112D820CA06480B09841C247C5314CC440100' & _
		   '57AE547FB5F32CF7B69E0F63D87675F47F2D7C1C06D8FB0E1E49EF0CECEFEFCF' & _
		   'C9C9292C2C4C4E4E9E376FDEC48913994C26499277EFDE3D71E2447676B6A370' & _
		   'ECBC416CC3860D8585858EC5ACDCDCDC3B77EE6CDAB4292E2E4E24129124D9DA' & _
		   'DA7AE5CA95ECEC6CFB5C6CEBD6ADB9B9B91A8D6684520742616C8CC7A0A7BEC8' & _
		   '2A9EDECA10416C0320488A8200E4CD46676E9E11B82E1200505070EB54EADFA7' & _
		   '9A3D2C804950C0A2323E26037EF5CAD86099190C009048247BF6EC8120C8C3C3' & _
		   'C37E44A7D3394FA7DF7DF75DE7B5770E8773F4E8D1C58B17373535D98F545454' & _
		   'BCF6DA6B1C0EC71ED40C0683FD097300C0ABAFBEBA7DFBF6C3870FFF9A66FECB' & _
		   '2DC3C68DF684300B454210E03390D040CFA7DF9F1FB12F0142A09696BE2F37FD' & _
		   '3DDAE005480A10408020C18BC63D3EEA0CCB1EC7DE61A3D1E87A84A728CA51B8' & _
		   '1B3699709480C1CF57CE9D978DECFB0FD56AB55AAD76F086CBE5EEDBB7EF9D77' & _
		   'DE19A070ECD8B14545450B17FE6C78361A8DF6E676DEC030BC6DDB36FB4E50C7' & _
		   '1D0ED81CED58FDB6BF7D67D8B28B438F7D27D363AF26AF4D5FDCC6F6565F6BA3' & _
		   '6020FCB751A2651378E1F7F7DC97DCA80F5330488A8228888FA0E17382029686' & _
		   'FD8ABF8F9898182E970BC3308FC773F178833D882C5EBC58AD5653143571E244' & _
		   'D77170CC9831F1F1F1288ADA6C36E78D573B77EE0C0A0A3A7DFAF4EDDBB7ED33' & _
		   'A97FA6F9A8582C4E4848D8B469D3507B3FC2C2C22E5CB870ECD8B1DCDCDCAAAA' & _
		   '2AE7FDCB3E3E3EF3E7CFDFB469537C7CBC5DDB92254B701C27086280B6C8C848' & _
		   'B95C8E200804413E3E3EAE3B87C964C6C7C77777775314151212E2FE6359D0E3' & _
		   '581EABAD693FF5629E5F2B0EA120242630FAB3448F9F17007F33B05765EC7F1F' & _
		   '4EC23A3B3B9B9A9A944A2545510C06232020202C2CCCCDD54D92249B9A9A1A1B' & _
		   '1B8D46A39D0193264D1A356AD4C8B11D7A4C2BAB25672AF17C09C6C7C236CFF4' & _
		   '9E190068FCE6003DBE45791ABF6DD0EFC1A7415387064D1D1A347568D0D4A141' & _
		   '83A60E0D9A3A3468EAD0A0A94383A60E0D1A3475683C36FCEF00A7516BFF8067' & _
		   'B69A0000000049454E44AE426082'

	Return Binary($bImage)
EndFunc   ;==>_Image_MSDNLogo
