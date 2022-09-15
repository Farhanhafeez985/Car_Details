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
    for row in csv.DictReader(open(file_name, encoding='utf-8', errors='ignore', mode='r')):
        try:
            kba_nr = row['INDEX AP']
            kba_nrs.append(kba_nr)
        except:
            pass
    return kba_nrs


def get_kba_form_db(kba_nrs):
    ktyp_nrs = []
    kba_nrs = tuple(kba_nrs)
    params = {'kba_nrs': kba_nrs}
    retrive = """SELECT T121.KTYPNR FROM `121` AS T121 WHERE T121.KBANR IN %(kba_nrs)s;"""
    cursor.execute(retrive, params)
    # print(cursor._last_executed)
    rows = cursor.fetchall()
    for row in rows:
        ktyp_nrs.append(row[0])
    return ktyp_nrs


if __name__ == '__main__':
    kba_nrs = read_csv_file('3168590-New.csv')

    ktyp_nrs = get_kba_form_db(kba_nrs)
    print(len(ktyp_nrs))
    for ktyp_nr in ktyp_nrs:
        query = r"""SELECT
                        T120.KTYPNR AS `KTYPNR`,
                        tcd_04_2022.GET_LBEZNR(T100.LBEZNR, 1) AS MANUFACTURER,  -- NAME MANUFACTURER
                        tcd_04_2022.GET_LBEZNR(T110.LBEZNR, 1) AS MODEL,  -- NAME MODEL
                        tcd_04_2022.GET_LBEZNR(T120.LBEZNR, 1) AS TYPE,  -- NAME TYPE
                        T120.BJVON AS `BJVON`,
                        IFNULL(T120.BJBIS, 'to now') AS `BJBIS`,
                        IFNULL(T120.KW, '') AS `KW`,
                        IFNULL(T120.PS, '') AS `PS`,
                        IFNULL(T120.CCMSTEUER, '') AS `CCMSTEUER`,
                        IFNULL(T120.CCMTECH, '') AS `CCMTECH`,
                        IFNULL(T120.LIT, '') AS `LIT`,
                        IFNULL(T120.ZYL, '') AS `ZYL`,
                        IFNULL(T120.TUEREN, '') AS `TUEREN`,
                        IFNULL(T120.TANKINHALT, '') AS `TANKINHALT`,
                        IFNULL(T120.SPANNUNG, '') AS `SPANNUNG`,
                        IFNULL((CASE
                                WHEN T120.ABS = 0 THEN 'NO'
                                WHEN T120.ABS = 1 THEN 'YES'
                                WHEN T120.ABS = 2 THEN 'OPTIONAL'
                                WHEN T120.ABS = 9 THEN 'UNKNOWN'
                                ELSE NULL
                                END), '') AS `ABS`,
                        IFNULL((CASE
                                WHEN T120.ASR = 0 THEN 'NO'
                                WHEN T120.ASR = 1 THEN 'YES'
                                WHEN T120.ASR = 2 THEN 'OPTIONAL'
                                WHEN T120.ASR = 9 THEN 'UNKNOWN'
                                ELSE NULL
                                END), '') AS `ASR`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(80, T120.MOTART, 1), '') AS `MOTART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(97, T120.KRAFTSTOFFAUFBEREITUNGSPRINZIP, 1), '') AS `KRAFTSTOFFAUFBEREITUNGSPRINZIP`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(82, T120.ANTRART, 1), '') AS `ANTRART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(83, T120.BREMSART, 1), '') AS `BREMSART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(84, T120.BREMSSYS, 1), '') AS `BREMSSYS`,
                        IFNULL(T120.VENTILE_BRENNRAUM, '') AS `VENTILE_BRENNRAUM`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(182, T120.KRSTOFFART, 1), '') AS `KRSTOFFART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(89, T120.KATART, 1), '') AS `KATART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(85, T120.GETRART, 1), '') AS `GETRART`,
                        IFNULL(tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(86, T120.AUFBAUART, 1), '') AS `AUFBAUART`,
                        IFNULL((SELECT GROUP_CONCAT(DISTINCT T155.MCODE SEPARATOR ', ')
                                FROM `125` AS T125 JOIN `155` AS T155 ON T155.MOTNR = T125.MOTNR
                                WHERE T125.KTYPNR = T120.KTYPNR), '') AS LISTENGINES
                    FROM `120` AS T120
                        JOIN `110` AS T110 ON T110.KMODNR = T120.KMODNR
                        JOIN `100` AS T100 ON T100.HERNR = T110.HERNR
                    WHERE T120.KTYPNR = %s;"""
        cursor.execute(query, ktyp_nr)
        with open('KTYPNR_Result.csv', 'a', encoding='utf-8') as f:
            writer = csv.writer(f, lineterminator='\n')
            writer.writerows(cursor.fetchall())
