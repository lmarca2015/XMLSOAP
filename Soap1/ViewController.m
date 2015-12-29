//
//  ViewController.m
//  Soap1
//
//  Created by Procesos on 29/12/15.
//  Copyright © 2015 PMP. All rights reserved.
//

#import "ViewController.h"

#define TAG_AFILIACION @"AfiliacionResult"
#define TAG_PAGOS @"PagosResult"
#define TAG_TRANSFERENCIA @"TransferenciaResult"
#define TAG_RECARGAS @"RecargaResult"


#define SERVICE_AFILIACION @"http://tempuri.org/IService/Afiliacion"
#define SERVICE_PAGOS @"http://tempuri.org/IService/Pagos"
#define SERVICE_TRANSFERENCIA @"http://tempuri.org/IService/Transferencia"
#define SERVICE_RECARGA @"http://tempuri.org/IService/Recarga"


@interface ViewController () <NSURLConnectionDelegate,NSXMLParserDelegate>
@property NSString *soapMessage;
@property NSString *currentElement;
@property NSMutableData *webResponseData;
@property NSMutableString *soapResultsPortFolio;
@property BOOL elementFoundPortFolio;

@end

@implementation ViewController

@synthesize soapMessage, webResponseData, currentElement, soapResultsPortFolio, elementFoundPortFolio;

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    NSString *soap = @"<![CDATA[\n"
    "<Afiliacion>\n"
    "<Data>\n"
    "Tarjeta=5549110920049586|Tag=000|Emisor=064|Tipo Documento=1|Nro  Documento=90876643|Codigo Cliente=0000641000012345678|Nombre=Luis|\n"
    "Apellidos=Marca Zapata|Mail=luisfmz26@gmail.com|Celular=990044551|Fecha Nacimiento=19830521|Via=Av|Direccion=Calle Odriozola|Nro=171|Ubigeo\n"
    "=101015|Codigo Relacion=0010641000012345678\n"
    "</Data>\n"
    "</Afiliacion>\n"
    "]]>";
    */
    
    /*
    NSString *soap = @"<![CDATA[\n"
    "<Pagos>\n"
    "<Data>\n"
    "Servicio=Sedapal|TipoOperador=Sedapal|NroServicio=123456789|FechaDeuda=20151120|Monto=100.00\n"
    "</Data>\n"
    "</Pagos>\n"
    "]]>";
    */
    
    /*
    NSString *soap = @"<![CDATA[\n"
    "<Transferencia>\n"
    "<Data>\n"
    "Monto=100.00|Cuenta=12345678900|Tarjeta=5549110920049586|Pin=123\n"
    "</Data>\n"
    "</Transferencia>\n"
    "]]>";
    */
    
    NSString *soap = @"<![CDATA[\n"
    "<Recarga>\n"
    "<Data>\n"
    "Tarjeta Abono=5549110920049586|Medio Recarga=Tarjeta|Tarjeta Recargo=5549110920049587|Pin=123|Nro Cta Abono=001123456789|Monto=100.00\n"
    "</Data>\n"
    "</Recarga>\n"
    "]]>";
    
    //TODO: Cambiar el tipo de operacion..
    NSString *envelope = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"http://tempuri.org/\"><SOAP-ENV:Body><ns1:Recarga><ns1:xml>%@</ns1:xml></ns1:Recarga></SOAP-ENV:Body></SOAP-ENV:Envelope>",soap];

    
    NSString *envelopeLength = [NSString stringWithFormat:@"%lu", (unsigned long)envelope.length];
    
    NSURL *url = [NSURL URLWithString:@"https://testws.punto-web.com/wcfBonus/Service.svc"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:envelopeLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:SERVICE_RECARGA forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [envelope dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];

    /*
    NSURLSession *session = [NSURLSession sharedSession];
    [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                     NSURLResponse * _Nullable response,
                                                     NSError * _Nullable error) {
        //hanfle response.
    }];
    */
    
    if (connection)
        webResponseData = NSMutableData.data;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [webResponseData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Received %lu bytes", (unsigned long)webResponseData.length);
    
    NSXMLParser *xmlParse = [[NSXMLParser alloc] initWithData:webResponseData];
    [xmlParse setDelegate:self];
    [xmlParse setShouldResolveExternalEntities:YES];
    [xmlParse parse];
    
    /*
    NSString *response = [[NSString alloc] initWithData:webResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", response);*/
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    //NSLog(@"%@",elementName);
    if( [elementName isEqualToString:TAG_RECARGAS])
    {
        if (!soapResultsPortFolio)
        {
            soapResultsPortFolio = [[NSMutableString alloc] init];
            elementFoundPortFolio = YES;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //NSLog(@"%@",string);
    if ([ViewController listMatches:@"DEPOSITO" stringT:string]) {
        if (elementFoundPortFolio)
        {
            [soapResultsPortFolio appendString: string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:TAG_RECARGAS])
    {
        //NSLog(@"didEndElement ->%@",soapResultsPortFolio);
        self.textView.text = soapResultsPortFolio;
        elementFoundPortFolio = false;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Parser error %@ ",[parseError description]);
}

+ (BOOL )listMatches: (NSString *)pattern stringT:(NSString *)string{
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionIgnoreMetacharacters error:nil];
    NSRange range = NSMakeRange(0, [string length]);
    NSUInteger regExMatches = [regEx numberOfMatchesInString:string options:0 range:range];
    if (regExMatches == 0) {
        return false;
    }else{
        return true;
    }
}


@end
