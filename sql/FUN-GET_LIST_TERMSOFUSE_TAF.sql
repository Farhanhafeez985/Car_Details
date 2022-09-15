DELIMITER $$
CREATE FUNCTION `GET_LIST_TERMSOFUSE_TAF`(DLNR INT, ARTNUM VARCHAR(105) CHARSET utf8, IDCAR INT,
                                          LANG VARCHAR(3) CHARSET utf8) RETURNS text CHARSET utf8
    DETERMINISTIC
BEGIN
    DECLARE RES TEXT;

    set @lngidtermsofuse = IFNULL((select SPRACHNR from tcd_04_2022.`020` where ISO_CODE = LANG limit 1), 0);

    SET RES = (
        select group_concat(distinct
                            concat(
                                    tcd_04_2022.GET_BEZNR(T050.BEZNR, @lngidtermsofuse), ' : ',
                                    ifnull(IF(T050.TYP = 'K',
                                              tcd_04_2022.GET_BEZNR_FOR_KEY_TABLE(T050.TABNR, T410.KRITWERT,
                                                                             @lngidtermsofuse),
                                              IF(T050.TYP = 'D',
                                                 CONCAT(RIGHT(T410.KRITWERT, 2), '/', LEFT(T410.KRITWERT, 4)),
                                                 IF(T410.KRITNR = 14, IFNULL((SELECT T155.MCODE
                                                                              FROM tcd_04_2022.`155` as T155
                                                                              WHERE T155.MOTNR = T410.KRITWERT
                                                                              LIMIT 1), ''), T410.KRITWERT))
                                               ), '')
                                )
                            separator ', ')

        from tcd_04_2022.`410` as T410
                 join tcd_04_2022.`200` as T200 on T410.ARTNR = T200.ARTNR and T410.DLNR = T200.DLNR
                 JOIN tcd_04_2022.`050` AS T050 ON T050.KRITNR = T410.KRITNR and T050.DLNR IN (9999, T410.DLNR)

        WHERE T200.ARTNR = ARTNUM
          AND T200.DLNR = DLNR
          AND T410.VKNZIELNR = IDCAR
          and T410.VKNZIELART = 2

        order by T410.SORTNR
    );

    RETURN RES;

END$$
DELIMITER ;
