#include <Trade/Trade.mqh> // module for trading

CTrade trade; //this is a class, object variable of type CTrade named "trade" (this can be changed)

int rsiHandle;
int macdHandle;
ulong posTicket; //global ticket variable i.e. trade ID
//double tradePrice;


double SLperc = 0.004;
double TPperc = 0.004;
double SLabs = 0.002;
double TPabs = 0.005;

int OnInit()
{
   Print("OnInit"+_Symbol);
   
   rsiHandle = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE); //iRSI("EURUSD",5,14,PRICE_CLOSE);
   macdHandle = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE); //iRSI("EURUSD",5,14,PRICE_CLOSE);
   
   return 0;
}
  
void OnDeinit(const int reason)
{
   Print("OnDeInit");
}
  
void OnTick()
{
   //check conditions, open or close trades, modify positions
   double rsi[]; // empty array for RSI
   double macd[]; // empty array for MACD
   
   CopyBuffer(rsiHandle, 0, 1,1,rsi); 
   // handle, buffer number 0 starts from 0 only one buffer, starting pos, count (how many candles before 1st, number of values in array), array
   // if more than one candle calculated, then the most recent one is in the last array position, the one furthest back in time is at 0
   CopyBuffer(macdHandle, 0, 1,2,macd); // macd has 2 buffers MACDbuffer and Signalbuffer, we are interested in the first
   
   // SELL POSITION
   if (rsi[0] > 70 && macd[1] < macd[0]){ // && rsi[1] < rsi[0]
      Print("rsi = ",rsi[0]);
      Print("macd=",macd[0],"<",macd[1]);
      //Close buy position if there is a sell signal
      if (posTicket > 0 && PositionSelectByTicket(posTicket)){
         int posType = (int) PositionGetInteger(POSITION_TYPE);
         if (posType == POSITION_TYPE_BUY){
            trade.PositionClose(posTicket);
            posTicket = 0;
         }
      }
      if (posTicket <= 0){ //if ticket ID (trade ID) larger smaller or equal 0, open trade. As soon as 1 trade is open, ticket ID is larger 0.
         trade.Sell(0.01,_Symbol); //price set top 0 is market price, sl = stop loss, tp = take profit
         posTicket = trade.ResultOrder(); //need to stop buy/sell at every tick by identifying uinque trade ID
         //tradePrice = trade.RequestPrice();
      }
      // BUY POSITION
   } else if (rsi[0] < 30 && macd[1] > macd[0]){ // rsi[1] < 30 && rsi[1] > rsi[0]
      Print("rsi = ",rsi[0]);
      Print("macd=",macd[0],">",macd[1]);
      Print("macd = ",macd[0]);
      //Close sell position if there is a sell signal
      if (posTicket > 0 && PositionSelectByTicket(posTicket)){
         int posType = (int) PositionGetInteger(POSITION_TYPE);
         if (posType == POSITION_TYPE_SELL){
            trade.PositionClose(posTicket);
            posTicket = 0;
         }
      }
      if (posTicket <= 0){
         trade.Buy(0.01,_Symbol);
         posTicket = trade.ResultOrder();
         //tradePrice = trade.RequestPrice();
      }
   }
   //modiify trade
   if (PositionSelectByTicket(posTicket)){
      double posPrice = PositionGetDouble(POSITION_PRICE_OPEN); //get price at position opening
      double posSL = PositionGetDouble(POSITION_SL); //get stop loss price
      double posTP = PositionGetDouble(POSITION_TP); //get take profit price
      int posType = (int) PositionGetInteger(POSITION_TYPE); //get position type, add (int) before to define that this is an integer
          
      //For Long position
      if (posType == POSITION_TYPE_BUY){
            if (posSL == 0){
            double sl = posPrice - SLabs; //posPrice - 0.006 // - (posPrice * SLperc) // 0.0001 is one pip, 0.001 is 10 pips
            double tp = posPrice + TPabs; //posPrice + 0.006 // + (posPrice * TPperc)
            trade.PositionModify(posTicket,sl,tp);
         }
      } else if (posType == POSITION_TYPE_SELL){ //For Short position
         if (posSL == 0){
            double sl = posPrice + SLabs; //posPrice + 0.006 // + (posPrice * SLperc)
            double tp = posPrice - TPabs; //posPrice - 0.006 // - (posPrice * SLperc)
            trade.PositionModify(posTicket,sl,tp);
         }
      }
   } else {
      posTicket = 0; //need  to set to 0 again, otherwise posTicket stays above 0 and no new trades are opened
     }
   
   Comment("RSI=",rsi[0],"\n","MACD=",macd[1],"\n","Ticket=",posTicket,"\n","TradePrice=");
}

int ourFunction(string txt)
{
   Print("this is our function"+txt);
   return 1;
}
