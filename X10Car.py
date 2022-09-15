import csv

import pymysql
from pymssql import OperationalError

connection = pymysql.connect(host="95.217.228.123", user="tcd", passwd="78fhbneE6JppMK", database="tcd_04_2022")
cursor = connection.cursor()


def executeScriptsFromFile(filename):
    fd = open(filename, 'r')
    sql_file = fd.read()
    fd.close()
    sql_commands = sql_file.split(';')

    for command in sql_commands:
        try:
            cursor.execute(command)
        except OperationalError as msg:
            print("Command skipped: ", msg)
    return cursor


def read_csv_file(file_name):
    kba_nrs = []
    art_nrs = []
    for row in csv.DictReader(open(file_name, encoding='utf-8', errors='ignore', mode='r')):
        data = row.get('INDEX AP;Name;INDEX TECDOC;Brandcode AP;Brandcode TECDOC', '').split(';')
        try:
            kba_nr = data[0]
            kba_nrs.append(kba_nr)
        except:
            pass
        try:
            art_nr = data[2]
            art_nrs.append(art_nr)
        except:
            pass
    return kba_nrs, art_nrs


def get_kba_form_db(kba_nrs, art_rns):
    ktyp_nrs = []
    for kba_nr in kba_nrs:
        try:
            retrive = """SELECT T121.KTYPNR FROM `121` AS T121 WHERE T121.KBANR = %s"""
            cursor.execute(retrive, (kba_nr,))
            rows = cursor.fetchall()
            for row in rows:
                print(row[0])
                ktyp_nrs.append(row[0])
        except:
            continue
    # eannrs = []
    # art_rns = tuple(art_rns)
    # params = {'art_rns': art_rns}
    # retrive = "SELECT T209.EANNR FROM `209` AS T209 WHERE T209.ARTNR IN %(art_rns)s;"
    # cursor.execute(retrive, params)
    # rows = cursor.fetchall()
    # for row in rows:
    #     eannrs.append(row[0])
    return ktyp_nrs  # , eannrs


if __name__ == '__main__':
    # executeScriptsFromFile('x10car-SQL-TABLE-EBAYIDCATEGORIES.sql') # Create table ebay_gaid
    # data = executeScriptsFromFile('sql/x10car-SQL-QUERY-FILEEXCHANGE-new-2.sql')
    # Read KBANR form CSV and get KTYPENR for Tecdoc db...
    kba_nrs, art_rns = read_csv_file('3168590.csv')
    ktyp_nrs = get_kba_form_db(kba_nrs, art_rns)
    print(ktyp_nrs)
    print('s')
    # for ktyp_nr in ktyp_nrs:
    #     query = r"""SELECT
    #                     T120.KTYPNR AS `KTYPNR`,
    #                     tcd_04_2022.GET_LBEZNR(T100.LBEZNR, 1) AS MANUFACTURER,  -- NAME MANUFACTURER
    #                     tcd_04_2022.GET_LBEZNR(T110.LBEZNR, 1) AS MODEL,  -- NAME MODEL
    #                     tcd_04_2022.GET_LBEZNR(T120.LBEZNR, 1) AS TYPE,  -- NAME TYPE
    #                     T120.BJVON AS `BJVON`,
    #                     IFNULL(T120.BJBIS, 'to now') AS `BJBIS`,
    #                     IFNULL(T120.KW, '') AS `KW`,
    #                     IFNULL(T120.PS, '') AS `PS`,
    #                     IFNULL(T120.CCMSTEUER, '') AS `CCMSTEUER`,
    #                     IFNULL(T120.CCMTECH, '') AS `CCMTECH`,
    #                     IFNULL(T120.LIT, '') AS `LIT`,
    #                     IFNULL(T120.ZYL, '') AS `ZYL`,
    #                     IFNULL(T120.TUEREN, '') AS `TUEREN`,
    #                     IFNULL(T120.TANKINHALT, '') AS `TANKINHALT`,
    #                     IFNULL(T120.SPANNUNG, '') AS `SPANNUNG`,
    #                     IFNULL((CASE
    #                             WHEN T120.ABS = 0 THEN 'NO'
    #                             WHEN T120.ABS = 1 THEN 'YES'
    #                             WHEN T120.ABS = 2 THEN 'OPTIONAL'
    #                             WHEN T120.ABS = 9 THEN 'UNKNOWN'
    #                             ELSE NULL
    #                             END), '') AS `ABS`,
    #                     IFNULL((CASE
    #                             WHEN T120.ASR = 0 THEN 'NO'
    #                             WHEN T120.ASR = 1 THEN 'YES'
    #                             WHEN T120.ASR = 2 THEN 'OPTIONAL'
    #                             WHEN T120.ASR = 9 THEN 'UNKNOWN'
    #                             ELSE NULL
    #                             END), '') AS `ASR`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(80, T120.MOTART, 1), '') AS `MOTART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(97, T120.KRAFTSTOFFAUFBEREITUNGSPRINZIP, 1), '') AS `KRAFTSTOFFAUFBEREITUNGSPRINZIP`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(82, T120.ANTRART, 1), '') AS `ANTRART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(83, T120.BREMSART, 1), '') AS `BREMSART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(84, T120.BREMSSYS, 1), '') AS `BREMSSYS`,
    #                     IFNULL(T120.VENTILE_BRENNRAUM, '') AS `VENTILE_BRENNRAUM`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(182, T120.KRSTOFFART, 1), '') AS `KRSTOFFART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(89, T120.KATART, 1), '') AS `KATART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(85, T120.GETRART, 1), '') AS `GETRART`,
    #                     IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(86, T120.AUFBAUART, 1), '') AS `AUFBAUART`,
    #                     IFNULL((SELECT GROUP_CONCAT(DISTINCT T155.MCODE SEPARATOR ', ')
    #                             FROM `125` AS T125 JOIN `155` AS T155 ON T155.MOTNR = T125.MOTNR
    #                             WHERE T125.KTYPNR = T120.KTYPNR), '') AS LISTENGINES
    #                 FROM `120` AS T120
    #                     JOIN `110` AS T110 ON T110.KMODNR = T120.KMODNR
    #                     JOIN `100` AS T100 ON T100.HERNR = T110.HERNR
    #                 WHERE T120.KTYPNR = %s;"""
    #     cursor.execute(query, ktyp_nr)
    #     with open('ktypnr_result.csv', 'a', encoding='utf-8') as f:
    #         writer = csv.writer(f, lineterminator='\n')
    #         writer.writerows(cursor.fetchall())

    # with open('output.csv', 'w', encoding='utf-8') as f:
    #     headers = ['Action',
    #                'Category',
    #                'CustomLabel',
    #                'Title',
    #                'ConditionID',
    #                'Product',
    #                'C:Brand',
    #                'C:MPN',
    #                'C:CrossReference',
    #                'Weight',
    #                'PicURL',
    #                'GalleryType',
    #                'Description',
    #                'Format',
    #                'Duration',
    #                'StartPrice',
    #                'Quantity',
    #                'PayPalAccepted',
    #                'PayPalEmailAddress',
    #                'ImmediatePayRequired',
    #                'PaymentInstructions',
    #                'Location',
    #                'ShippingService-1:Option',
    #                'ShippingService-1:FreeShipping',
    #                'ShippingService-1:Cost',
    #                'IntlShippingService-1:Option',
    #                'IntlShippingService-1:Locations',
    #                'IntlShippingService-1:Cost',
    #                'IntlShippingService-1:AdditionalCost',
    #                'IntlShippingService-1:Priority',
    #                'DomesticRateTable',
    #                'ShippingType',
    #                'WeightMajor',
    #                'WeightMinor',
    #                'InternationalRateTable',
    #                'DispatchTimeMax',
    #                'ReturnsAcceptedOption',
    #                'RefundOption',
    #                'ReturnsWithinOption',
    #                'OutOfStockControl',
    #                'ShippingCostPaidBy',
    #                'AdditionalDetails',
    #                'Relationship',
    #                'RelationshipDetails', ]
    #     writer = csv.writer(f, lineterminator='\n')
    #     for row in data.fetchall():
    #         writer.writerow(list(row))
    # for data in cursor.fetchall():
    #     print(data)
