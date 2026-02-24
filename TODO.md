* table caching is disables in favor of chunk processing. re-enable later if needed.
* validate config option values
* add data member to table.placement to track if the table is in a comment or not
* support comment strings with RHS, e.g. /* table */
* InsertCol should adjust col align/width
* change insert/delete behavior to use draw#CurrentlyPlaced. Perhaps just use
textobjects for deleting and just insert cols/rows directly without parsing the
table (after draw#CurrentlyPlaced)
