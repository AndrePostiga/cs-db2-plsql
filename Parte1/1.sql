SELECT
    ALL_INDEXES.OWNER,
    ALL_INDEXES.INDEX_NAME,
    ALL_INDEXES.TABLE_OWNER,
    ALL_INDEXES.TABLE_NAME,
    ALL_IND_COLUMNS.COLUMN_NAME
FROM
    ALL_INDEXES
LEFT JOIN ALL_IND_COLUMNS ON ALL_IND_COLUMNS.INDEX_NAME = ALL_INDEXES.INDEX_NAME
WHERE
    ALL_INDEXES.OWNER = 'CHINOOK';