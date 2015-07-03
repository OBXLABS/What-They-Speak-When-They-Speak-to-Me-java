/*
 Copyright (C) <2015>  <Jason Lewis>
  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the BSD 3 clause with added Attribution clause license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   BSD 3 clause with added Attribution clause License for more details.
   */
abstract class SnakePath extends InputSource {
    double pointDistance;
    HashMap paths = new HashMap();
    HashMap leaders = new HashMap();
    
    Book book;

    /**
     * Get the leader for a specified path.
     *
     * @param path_id id of the path
     */
    public TextObject getLeader(Integer path_id) {
      return (TextObject)leaders.get(path_id); 
    }

    /**
     * Set the leader for a specified path.
     *
     * @param to leader text object
     * @param path_id id of the path it is leading
     */
    public void setLeader(TextObject to, Integer path_id) {
      synchronized(leaders) {
        leaders.put(path_id, to);
      }
      ((BooleanProperty)to.getProperty("Leader")).set(true);
      ((NumberProperty)to.getProperty("PathId")).set(path_id.intValue());        
    }
    
    /**
     * Unset the leader for a specified path.
     *
     * @param path_id id of the path it is leading
     */    
    public void unsetLeader(Integer path_id) {
      synchronized(leaders) {
        TextObject to = (TextObject)leaders.get(path_id);
        if (to != null) {
          ((BooleanProperty)to.getProperty("Leader")).set(false);
          ((NumberProperty)to.getProperty("PathId")).set(-1);
        }
        
        leaders.remove(path_id);
      }
    }
    
    /** 
     * Recursively sets the 'Follower' property for the TextObject and its right siblings
     *
     * @param to the TextObject to act upon
     * @param follow the value of the Follower property
     */
    public void setFollower(TextObject to, boolean follow) {
    	if (to == null) return ;
        
    	BooleanProperty followProperty = (BooleanProperty)to.getProperty("Follower");
  	followProperty.set(follow);

        TextObject rightSibling = to.getRightSibling();
        if (rightSibling == null) {
            if (to.getParent() == null) return;
            else {
                TextObjectGroup rightParent = (TextObjectGroup)to.getParent().getRightSibling();
                if (rightParent == null) return;
                rightSibling = rightParent.getLeftMostChild();
            }
        }

        setFollower(rightSibling, follow);
    }
    
    /**
     * Gets a copy of the path
     *
     * @return the path
     */
    public ArrayList getPath(Integer path_id) {
        synchronized (paths) {
            ArrayList copy = new ArrayList();
            
            if (paths.containsKey(path_id)) {
              ArrayList orig = (ArrayList)paths.get(path_id);
              for(int i = 0; i < orig.size(); i++)
                copy.add(((Point)orig.get(i)).clone());
            }
            
            return copy;
        }
    }

    /**
     * Gets a copy of the paths
     *
     * @return the path
     */
    public HashMap getPaths() {
        synchronized (paths) {
            HashMap copy = new HashMap();

            Iterator it = paths.keySet().iterator();
            Object key;
            while(it.hasNext()) {
              key = it.next();
              copy.put(key, getPath((Integer)key));
            }
            return copy;
        }
    }
}
