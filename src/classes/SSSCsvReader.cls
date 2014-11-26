/**
 * Used to read a delimited file.
 */
global class SSSCsvReader implements Iterator<SSSCsvRow>, Iterable<SSSCsvRow> {
    private String delim = ',';
    // the input data
    private String[] buffer;

    private Integer rowNumber = 2;
    
    private SSSCsvRow now;
    
    private SSSCsvRow next;
    
    private String[] heading;
    
    private Map<String, Integer> headingToIndex = new Map<String, Integer>();

    public SSSCsvReader(String data){
        this.buffer = data.split('\r\n?|\n');
        readHeader(); 
        //now = getRow();
        next = getRow();
    }

    private void readHeader() {
        heading = readLine();
        for (Integer i = 0; i< heading.size(); i++) {
            setHeading(heading[i], i);
        }
    }
    
    public String[] getHeadings() {
        return heading;
    }
    
    public void setHeading(String label, Integer index) {
        headingToIndex.put(label.toLowerCase(), index);
    }
    
    public Map<String, Integer> getHeadingToIndex() {
        return headingToIndex;
    }
    
    private SSSCsvRow getRow() {
        String[] line = readLine();
        if (line == null) {
            return null;
        }
        return new SSSCsvRow(this, rowNumber++, line);
    }
    
    global boolean hasNext(){ 
       return (next != null);
   }    

    global SSSCsvRow next(){
        now = next;
        next = getRow();
        return now;
    }
    

    /**
     * Read and parse next available line.  Return null if end of stream.
     */
    public String[] readLine(){
        if(buffer.size() == 0)
            return null;
        String line = this.buffer.remove(0);
        String[] parts = new String[] {};
        while(line != ''){
            Integer next = 0;
            if(line.startsWith('"')){
                line = line.substring(1); // strip initial
                Integer quoteIndex = findQuote(line, 0);
                while(quoteIndex == -1){
                    if(buffer.size() == 0){
                        // EOT!
                        quoteIndex = line.length();
                    } else { 
                        // grab the next line
                        Integer skip = line.length();
                        line += '\n' + this.buffer.remove(0);
                        quoteIndex = findQuote(line, skip);
                    }
                }
                // advance to comma
                next = quoteIndex + 1;
                parts.add(line.substring(0, quoteIndex).replace('""', '"'));
            } else {
                next = line.indexOf(this.delim, next);
                if(next == -1)
                    next = line.length();
                // NB in Substring, "endindex" is the index of the character AFTER the last index to get
                parts.add(line.substring(0, next));
            }       
            if(next == line.length() - 1)
                // case of a terminating comma.
                parts.add('');
            line = next < line.length() ? line.substring(next+1) : '';
        }
        if(parts.size() == 0)
            // empty string - we still want to return something...
            parts.add('');
        return parts;
    }

    static private Pattern quotePattern = Pattern.compile('(?<!")("")*"(?!")');
    /**
     * Find next quote in the line
     */
    static public Integer findQuote(String line, Integer skip){
        Matcher m = quotePattern.matcher(line);
        m.region(skip, m.regionEnd());
        if(!m.find())
            return -1;
        return m.end() - 1;
    }
    
    global Iterator<SSSCsvRow> Iterator(){
      return this;
    }
}