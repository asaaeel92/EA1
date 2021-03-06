//+------------------------------------------------------------------+
//|                                                          EA1.mq4 |
//|                                                     Asael Acosta |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Asael Acosta"
#property link      ""
#property version   "1.00"
#property strict
//Variables externas
extern int MA_Rapida   = 9;
extern int MA_Lenta    = 26;
extern int MA_Filtro   = 200;
extern double Lotaje   = 0.01;
extern int MagicNumber = 2018;
extern int StopLoss    = 0;
extern int TakeProfit  = 0;   

/*
+--------------------------------------------------------------------+
|              Comentarios sobre el funcionamiento del Expert Advisor|
+--------------------------------------------------------------------+
   1.- Este EA ha sido creado para la unica tarea de abrir operaciones
   dentro del mercado; lo que significa que el operador de este robot
   debe mantener vigilando las acciones que realiza para que en momen-
   tos dados, cierre las operaciones abiertas por este programa.
   
   2.- Es responsabilidad del OPERADOR de este robot cerrar las ope-
   raciones ya que no se cuenta con la programación necesaria para
   cerrarlas, si el operador no la cierra y llega volverse como per-
   didas será culpa unicamente del quien opera este robot.
   
   3.- Este robot tampoco cuenta con niveles de protección preestable-
   cidos, pero cuenta con la programación para poderselos configurar.
   
   4.- La versión se encuentra en fase de prueba por lo que seguirán 
   habiendo mejoras hasta declararse completado.
+--------------------------------------------------------------------+
|                              Funcionamiento de la estrategia del EA|
+--------------------------------------------------------------------+
   1.- La estrategia es simple, el EA abrirá una operación después de
   haber detectado un cruce de 2 medias móviles que deominaremos como
   Media Móvil Rápida (MA_Rapida)y Media Móvil Lenta (MA_Lenta), este
   cruce a su vez, deberá tener como filtro una Media Móvil que la de-
   noinamos como filtro (MA_Filtro).
      1.1.- Para las operaciones de compra, el 
*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  //------------------|Buscando ordenes abiertas|----------------------+
  int ordenes = RevisaLibro();

  if(ordenes > 0)//Sí hay ordenes abiertas, 
  {
    return;
  }
  else//No hay ordenes abiertas por este EA, buscamos señal
  {  
    //--------------------------|Variables|------------------------------+
    double ma_rapida=iMA(NULL,PERIOD_CURRENT,MA_Rapida,0,MODE_SMA,PRICE_CLOSE,1);
    double ma_lenta=iMA(NULL,PERIOD_CURRENT,MA_Lenta,0,MODE_SMA,PRICE_CLOSE,1);
    double ma_rapida_ant=iMA(NULL,PERIOD_CURRENT,MA_Rapida,0,MODE_SMA,PRICE_CLOSE,2);
    double ma_lenta_ant=iMA(NULL,PERIOD_CURRENT,MA_Lenta,0,MODE_SMA,PRICE_CLOSE,2);
    double ma_filtro=iMA(NULL,PERIOD_CURRENT,MA_Filtro,0,MODE_SMA,PRICE_CLOSE,1);

    //-----------------------|condición de compra|-----------------------+
    if(ma_filtro < Bid && ma_rapida > ma_lenta && ma_rapida_ant < ma_lenta_ant)
    {
      int ticket = OrderSend(NULL, OP_BUY, Lotaje, Ask, 10, StopLoss, TakeProfit, NULL, MagicNumber, 0, clrNONE);
    }

    //-------------------|condición de venta|----------------------------+
    if(ma_filtro > Ask && ma_rapida < ma_lenta && ma_rapida_ant > ma_lenta_ant)
    {
      int ticket=OrderSend(NULL, OP_SELL, Lotaje, Bid, 10, StopLoss, TakeProfit, NULL, MagicNumber, 0, clrNONE);
    }

    //-------------------------|cierre de compra|------------------------+
    //-------------------------|cierre de venta|-------------------------+
  }
}


int RevisaLibro()                                                      
{
  int OrdenesEA = 0;                                                //Contador de ordenes con Magic Number
  int OrdenesAbiertas = OrdersTotal();                                //Ordenes abiertas                                    
  bool Seleccionado = false;                                          //Controlador si pudo seleccionar o no una orden
  
  for (int i = 0; i < OrdenesAbiertas; i++)                                //Revisar todas las ordenes
  {
    Seleccionado = OrderSelect(i, SELECT_BY_TICKET, MODE_TRADES);            //Selecciona la orden por su posición en el libro por i
    if(Seleccionado && OrderMagicNumber() == MagicNumber)        //Si Magic Number coincide agrega 1 al contador
    {
      OrdenesEA++;
    }
  }
  
  if(OrdenesEA > 0)
  {
   Alert("Sube");
  }

  return(OrdenesEA);                                        //Devuelve el número de ordenes con Magic Number
}