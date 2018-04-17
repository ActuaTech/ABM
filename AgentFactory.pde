/**
* AgentFactory - Factory to generate diferent agents from diferent sources 
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
private class AgentFactory extends Factory {
    
    /**
    * Load Agents from a file
    * @param file    File with agents' definitions
    * @param roads   Roads where agents will be places
    * @return a list fo new agents
    */
    public ArrayList<Agent> load(File file, Roads roads) {

        print("Loading agents... ");
        ArrayList<Agent> agents = new ArrayList();
        int count = count();
        
        JSONArray JSONagents = loadJSONObject(file).getJSONArray("agents");
        for(int i = 0; i < JSONagents.size(); i++) {
            JSONObject agentGroup = JSONagents.getJSONObject(i);
            
            int id            = agentGroup.getInt("id");
            String name       = agentGroup.getString("name");
            String type       = agentGroup.getString("type");
            int amount        = agentGroup.getInt("amount");
            
            JSONObject style  = agentGroup.getJSONObject("style");
            String tint       = style.getString("color");
            int size          = style.getInt("size");
            
            for(int j = 0; j < amount; j++) {
                Agent agent = null;
                
                if(type.equals("PERSON")) agent = new Person(count, roads, size, tint);
                if(type.equals("CAR")) agent = new Vehicle(count, roads, size, tint);
                
                if(agent != null) {
                    agents.add(agent);
                    counter.increment(name);
                    count++;
                }
            }
        }
        println("LOADED");
        return agents;
    }
    
}
