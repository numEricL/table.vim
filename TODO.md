* table caching is disables in favor of chunk processing. re-enable later if needed.
* validate config option values
* add data member to table.placement to track if the table is in a comment or not
* support comment strings with RHS, e.g. /* table */
* change internal chunk_size to expect [positive, positive] numbers
* scan for alignment row when chunksize doesn't pick it up
