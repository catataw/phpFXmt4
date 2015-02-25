//+------------------------------------------------------------------+
//|                                         BreakermindMT4Copier.mq4 |
//|                             Copyright 2000-2015, Breakermind.com |
//|                                          https://breakermind.com |
//+------------------------------------------------------------------+
#property copyright   "© 2000-2015, Breakermind.com"
#property link        "https://breakermind.com"

input int    MoneyForSignalUSD = 100;
input string Username    = "woow";
input string Password    = "pass";
input bool   StartCopy   = true;
input int    ProviderId    = 66740257;
input bool   SSL         = false;


int  MagicNumber   = 777888;
double Lots        = 0.01;
int  Timer         = 300;

string url="localhost";

int Refresh = Timer;  
string apiurl;
string recived = "";
string empty = "";

void OnInit()
{
 if(Refresh < 300){ Refresh = 300; }
 EventSetMillisecondTimer(Refresh);       
 
   // api url http or https(ssl)
   if(SSL){
      apiurl = "https://" + url + "/copy.php"; 
   }
   if(!SSL){
      apiurl = "http://" + url + "/copy.php"; 
   }  

  if(MoneyForSignalUSD < 100)
    {
     Alert("1 Lot = 100000, Minimalny depozyt dla sygnału to 100USD [lub równowartość tej kwoty w innej walucie] i wielokrotność tej kwoty [200USD, 300USD, 400USD ...].");
     return;
    }

  if(MoneyForSignalUSD >= 100)
    {
      int multiply = (int)MoneyForSignalUSD / 100;
      Lots = Lots * multiply;
      Print("1 Lot Size = 100000 Base currency. Signal Deposit: " + multiply * 100 + "USD Lots size for position: " + Lots + ", Minimal lot size 0.01 (1000 base currency) micro lot." );
      Alert("1 Lot Size = 100000 Base currency. Signal Deposit: " + multiply * 100 + "USD Lots size for position: " + Lots + ", Minimal lot size 0.01 (1000 base currency) micro lot." );
    }

   if(!StartCopy){ Alert("Kopiowanie uruchamia się zmieniając parametr StartCopy na true - Klawisz F7 w MetaTrader4.");} 
    
}//end

void OnTimer(void)
  {
     
   char post[];
   char result[];
   string headers;
   int res;   
   string send = "";
   string copyhistory = "";
   bool setPosition = true;
   bool setPositionOpen = true;

   int j, chTotal;
   chTotal= OrdersHistoryTotal();
   for(j=0;j<chTotal;j++)
     {
      if(OrderType()<=OP_SELL){
         copyhistory = copyhistory + OrderOpenTime() + ";" + OrderTicket() + ";" + OrderOpenPrice() + ";" + OrderSymbol() + ";" + OrderLots() + ";" + OrderType() + ";" + OrderStopLoss() + ";" + OrderTakeProfit() + ";" + OrderCloseTime() + ";" + OrderClosePrice() + ";" + OrderProfit() + ";" + AccountNumber() +"|";
        }// if end
    }
    
        
   send =       
   "&user=" + Username + 
   "&pass=" + Password +
   "&id=" + ProviderId +
   "&money=" + MoneyForSignalUSD +
   "&account=" + AccountNumber() +
   "&leverage=" + AccountLeverage() +
   "&currency=" + AccountCurrency() +
   "&copyhistory=" + copyhistory +
   "&end=0";

   //Print("Master send: ",send);
   StringToCharArray(send,post);
   ResetLastError();
   res=WebRequest("POST",apiurl,NULL,NULL,50,post,ArraySize(post),result,headers);
   

   if(res==-1)
   {
      Print("Error code =",GetLastError());
      Print("Add address '"+apiurl+"' in Expert Advisors tab of the Options window","Error",MB_ICONINFORMATION);
   }else{
      
      if(CharArrayToString(result,0) != recived)
        {
         Print("Server response: ",CharArrayToString(result,0));
         recived = CharArrayToString(result,0);
        }
      //Print("Server response: ",CharArrayToString(result,0));
      
      string txt = CharArrayToString(result,0); // A string to split into substrings
      string sep = ";";                         // A separator as a character
      ushort c_sep;                             // The code of the separator character
      string pos[];                             // An array to get strings            
      c_sep=StringGetCharacter(sep,0);          //--- Get the separator code      
      int k=StringSplit(txt,c_sep,pos);         //--- Split the string to substrings
      if(k>0)
      {
         //Print(pos[6]);
      }
         
   }      
   if(txt != "[EMPTY]")
   {     
      if(!isOpen(pos[0]) && !isClose(pos[0]))
      {
       setOrder(pos);
      }
      
      modifyOrder(pos);
   }  
   
   if(txt == "[EMPTY]")
     {
      //Print("EMPTY - Close positions");
      closeAll();
     }

       
}//end
//+------------------------------------------------------------------+

void closeAll()
{
   int i, Total;
  
   Total=OrdersTotal();
   for(i=0;i<Total;i++)
   {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      if(OrderType() == OP_SELL){   
          int cls = OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);           
        }
      if(OrderType() == OP_BUY){   
          int clb = OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);           
        }
                
   }
   }  
 
}

void modifyOrder(string pos[])
{
   int i, Total;
   bool out = false;
   
   Total=OrdersTotal();
   for(i=0;i<Total;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderType() <= OP_SELL){   
         
           if(OrderComment() == pos[0] && OrderStopLoss() != pos[6]){
                OrderModify(OrderTicket(),OrderOpenPrice(),pos[6],OrderTakeProfit(),0,Green);  
           }
           if(OrderComment() == pos[0] && OrderTakeProfit() != pos[7]){
                OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),pos[7],0,Green);   
           }
                   
          }
        }
    }  
}

bool isOpen(string pos)
{
   int i, Total;
   bool out = false;
   
   Total=OrdersTotal();
   for(i=0;i<Total;i++)
   {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      if(OrderType() <= OP_SELL){   
        if(OrderComment() != pos){
          int cl = OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);           
        }
        if(OrderComment() == pos){
           // position exist return true
           out = true;
        }
       }
       }
   }  
 return out;    
}

bool isClose(string pos)
{
   int i, Total;
   bool out = false;
  
   Total= OrdersHistoryTotal();
   for(i=0;i<Total;i++)
     {     
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         if(OrderType()<=OP_SELL){
               if(OrderComment() == pos){
                  out = true;
               }               
         }
        }
     }
 return out;    
}


bool setOrder(string pos[])
{
   int Total = OrdersTotal();
   int ticket;  
   string comment = pos[0];
   Print("Order id: " + pos[0]);
      
   if(pos[2] == "buy" && OrdersTotal() == 0)
   {        
     ticket=OrderSend(pos[3],OP_BUY,Lots,Ask,3,pos[6],pos[7],comment,MagicNumber,0,DodgerBlue);
     if(ticket>0)
     {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
        Print("BUY order opened on Symbol " + pos[3] + " Lots " + pos[4] + " Price " + OrderOpenPrice());
        Alert("BUY order opened on Symbol " + pos[3] + " Lots " + pos[4] + " Price " + OrderOpenPrice());
        }
      }      
     }
         
      if(pos[2] == "sell" && OrdersTotal() == 0)
      {        
        ticket=OrderSend(pos[3],OP_SELL,Lots,Bid,3,pos[6],pos[7],comment,MagicNumber,0,Red);
         if(ticket>0)
         {
           if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
           Print("SELL order opened on Symbol " + pos[3] + " Lots " + pos[4] + " Price " + OrderOpenPrice());
           Alert("SELL order opened on Symbol " + pos[3] + " Lots " + pos[4] + " Price " + OrderOpenPrice());
           }
         }      
       }
return true;
}
