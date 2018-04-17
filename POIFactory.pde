/**
* POIFactory - Factory to generate diferent Points of Interest from diferent sources 
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
private class POIFactory extends Factory {
    
    /**
    * Load POIs from a file
    * @param file    File with POIs' definitions
    * @param roads   NodeFacade where POIs will be places
    * @return a list fo new POIs
    */
    public ArrayList<POI> load(File file, NodeFacade roads) {
        String fileName = file.getName();
        String extension = fileName.substring(fileName.lastIndexOf(".") + 1);
        switch(extension) {
            case "json": return loadJSON(file, roads);
            case "csv": return loadCSV(fileName, roads);
        }
        return new ArrayList();
    }
    
    
    /**
    * Load POIs form JSON file
    */
    private ArrayList<POI> loadJSON(File JSONFile, NodeFacade roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        
        JSONArray JSONPois = loadJSONObject(JSONFile).getJSONArray("features");
        for(int i = 0; i < JSONPois.size(); i++) {
            JSONObject poi = JSONPois.getJSONObject(i);
            
            JSONObject props = poi.getJSONObject("properties");
            
            String name    = props.isNull("NAME") ? "null" : props.getString("NAME");
            String type    = props.isNull("TYPE") ? "null" : props.getString("TYPE");
            int capacity   = props.isNull("CAPACITY") ? 0 : props.getInt("CAPACITY");
            
            JSONArray coords = poi.getJSONObject("geometry").getJSONArray("coordinates");
            PVector location = roads.toXY( coords.getFloat(1), coords.getFloat(0) );
                
            if( roads.contains(location) ) {
                pois.add( new POI(roads, str(count), name, type, location, capacity) );
                counter.increment(type);
                count++;
            }
             
        }
        println("LOADED");
        return pois;  
    }
      
    
    /**
    * Load POIs form CSV file
    */
    private ArrayList<POI> loadCSV(String path, NodeFacade roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        
        Table table = loadTable(path, "header");
        for(TableRow row : table.rows()) {
            
            String name         = row.getString("NAME");
            PVector location    = roads.toXY(row.getFloat("Y"), row.getFloat("X"));
            int capacity        = row.getInt("CAPACITY");
            String type         = row.getString("TYPE");
            int size            = 3;
            
            if( roads.contains(location) ) {
                pois.add( new POI(roads, str(count), name, type, location, capacity) );
                counter.increment(path); 
                count++;
            }
        }
        println("LOADED");
        return pois;
    }
     
}
