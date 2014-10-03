//+-----------------------------------------------------------------------------------------------+
//|                                                                MT4-Copier-breakermind-com.mq4 |
//+-----------------------------------------------------------------------------------------------+

#property copyright   "© breakermind.com All rights reserved."
#property link        "https://breakermind.com"


input string Username    = "woow";
input string Password    = "pass";

bool   ssl= false;
string url="localhost";
int    RefreshMilliseconds=1000;
string trade_mode;
string currency;
string company;
string apiurl;
string barstart;
string newbar;
string balance,equity;
int aftertotal = 0; 
string sendpositions = ""; 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

// Refresh after milisec
   EventSetMillisecondTimer(RefreshMilliseconds);
// api url http or https(ssl)
   if(ssl)
     {
      apiurl="https://"+url+"/s.php";
     }
   if(!ssl)
     {
      apiurl="http://"+url+"/s.php";
     }
// Name of the company
   company=AccountInfoString(ACCOUNT_COMPANY);
// Account currency
   currency=AccountInfoString(ACCOUNT_CURRENCY);
// Demo, contest or real account
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
// Now transform the value
   switch(account_type)
     {
      case  ACCOUNT_TRADE_MODE_DEMO:
         trade_mode="demo";
         break;
      case  ACCOUNT_TRADE_MODE_CONTEST:
         trade_mode="contest";
         break;
      default:
         trade_mode="real";
         break;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("Strategy stoped.");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
// Client's HTTP/S vars   
   char post[];
   char result[];
   char post1[];
   char result1[];
   string headers;
   int res,resh;
   string send="";
   string position="";
   string historyid="";
   string historyposition="";
  

// get orders history tickets id
   int ii,hTotal;
// !!!!!!! select order from history tab !!!!!!!
   hTotal= OrdersHistoryTotal();
   if(aftertotal != hTotal){
   aftertotal = 0;
   for(ii=0;ii<hTotal;ii++)
     {
     aftertotal = aftertotal + 1;
     Print("History positions: " + hTotal);
     Print("History positions send: " + aftertotal);
      if(OrderSelect(ii,SELECT_BY_POS,MODE_HISTORY)==false)
        {
         Print("History Error ",GetLastError());
         break;
        }
      // get history positions
      if(OrderType()<=OP_SELL)
        {
         string timeh   = OrderOpenTime();
         string ticketh = OrderTicket();
         string openh   = OrderOpenPrice();
         string lotsh    = OrderLots();
         string symbolh = OrderSymbol();
         string typeh   = OrderType();
         if(typeh == 0){ typeh = "BUY";}
         if(typeh == 1){ typeh = "SELL";}         
         string slh     = OrderStopLoss();
         string tph     = OrderTakeProfit();
         string profith = OrderProfit();
         string commenth= OrderComment();
         string closetimeh=OrderCloseTime();
         string closepriceh=OrderClosePrice();

         historyid = OrderTicket();
         historyposition = timeh+";"+ticketh+";"+openh+";"+symbolh+";"+lotsh+";"+typeh+";"+slh+";"+tph+";"+commenth+"[space]";                    
            
        }// if end

      // post data - send to server
      send=
           "&user="+Username+
           "&pass="+Password+
           "&haccountid="+AccountNumber()+
           "&hpositionid="+historyid+
           "&hposition="+historyposition+
           "&hclosetime="+closetimeh+
           "&hcloseprice="+closepriceh+
           "&hcloseprofit="+profith+
           "&command="+"[CLOSE]"+
           "&end="+"[OK]";

      Print(" Client's("+AccountNumber()+") send history position (ID: "+historyid+"): ",send);
      // pack to post array
      StringToCharArray(send,post);
      // reset last error
      ResetLastError();
      // post data to HTTP/HTTPS server API
      resh=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post),result,headers);
      int resendh=0;

      while(CharArrayToString(result,0)=="[ER]" || CharArrayToString(result,0)=="")
        {
         resendh=resendh+1;
         Print("Resend history position("+historyid+") times: "+resendh);
         resh=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post),result,headers);
         Sleep(2000);
        }

      // check errors
      if(resh==-1)
        {
         Print("Error code =",GetLastError());
         // maybe the URL is not added, show message to add it
         Print("Add address '"+apiurl+"' in (Tools)-> tab Options -> Strategy -> Allow WebRequest from add : "+apiurl);
         Print("Add address Error",MB_ICONINFORMATION);
         // if send error repeat

         while(resh==-1)
           {
            resendh=resendh+1;
            Print("Resend history position("+historyid+") times: "+resendh);
            Print("Add address '"+apiurl+"' in (Tools)-> tab Options -> Strategy -> Allow WebRequest from add : "+apiurl);
            Print("Add address Error",MB_ICONINFORMATION);
            resh=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post),result,headers);
            Sleep(2000);
           }
        }
      else
        {
         // successful
         Print("Server response : ",CharArrayToString(result,0));
        }        
     }// history end
}
// obtain the total number of orders
   int orders=OrdersTotal();
   if(orders == 0){
      Print("Waiting for new orders ...");
   }
   // scan the list of orders
   for(int i=0;i<orders;i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Get position error ",GetLastError());
         break;
        }

      // position id
      string positionid="0";
      // set position 
      if(OrderType()<=OP_SELL)
        {
         string time   = OrderOpenTime();
         string ticket = OrderTicket();
         string open   = OrderOpenPrice();
         string lots   = OrderLots();
         string symbol = OrderSymbol();
         string type   = OrderType();
         if(type == 0){ type = "BUY";}
         if(type == 1){ type = "SELL";}
         string sl     = OrderStopLoss();
         string tp     = OrderTakeProfit();
         string profit = OrderProfit();
         string comment= OrderComment();
         //if(comment == ""){comment = "[empty]";} 

         position=time+";"+ticket+";"+open+";"+symbol+";"+lots+";"+type+";"+sl+";"+tp+";"+comment+"[space]";
        }// end if position

      // post data - send to server
      send=
           "&user="+Username+
           "&pass="+Password+
           "&accountid="+AccountNumber()+
           "&positionid="+ticket+
           "&position="+position+
           "&command="+"[ADD]"+
           "&end="+"[OK]";

// 2014.10.02 22:23:59.163	MT4-5-Copier-breakermind-com GBPJPY,M1:  Client's(2106574) send position (ID: 104997441): &user=woow&pass=pass&accountid=2106574&positionid=104997441&position=1412279655;104997441;1.6147;GBPUSD;0.01;SELL;0;0;[space]&command=[ADD]&end=[OK]

      Print(" Client's("+AccountNumber()+") send position (ID: "+ticket+"): ",send);
      // pack to post array
      StringToCharArray(send,post1);
      // reset last error
      ResetLastError();
      // post data to HTTP/HTTPS server API
      res=WebRequest("POST",apiurl,NULL,NULL,50,post1,ArraySize(post),result1,headers);
      int resend=0;

      while(CharArrayToString(result1,0)=="[ER]" || CharArrayToString(result1,0)=="")
        {
         resend=resend+1;
         Print("Resend position("+ticket+") times: "+resend);
         res=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post1),result1,headers);
         Sleep(2000);
        }

      // check errors
      if(res==-1)
        {
         Print("Error code =",GetLastError());
         // maybe the URL is not added, show message to add it
         Print("Add address '"+apiurl+"' in (Tools)-> tab Options -> Strategy -> Allow WebRequest from add : "+apiurl);
         Print("Add address Error",MB_ICONINFORMATION);
         // if send error repeat

         while(res==-1)
           {
            resend=resend+1;
            Print("Resend position("+ticket+") times: "+resend);
            Print("Add address '"+apiurl+"' in (Tools)-> tab Options -> Strategy -> Allow WebRequest from add : "+apiurl);
            Print("Add address Error",MB_ICONINFORMATION);
            res=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post1),result1,headers);
            Sleep(2000);
           }
        }
      else
        {
         // successful
         Print("Server response : ",CharArrayToString(result1,0));
        }
     }// end for open positions 
  }
//+------------------------------------------------------------------+
