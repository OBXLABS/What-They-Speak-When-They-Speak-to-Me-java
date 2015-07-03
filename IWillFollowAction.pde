/*
 Copyright (C) <2015>  <Jason Lewis>
  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the BSD 3 clause with added Attribution clause license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   BSD 3 clause with added Attribution clause License for more details.
   */
import net.nexttext.TextObject;
import net.nexttext.property.BooleanProperty;
import net.nexttext.behaviour.physics.PhysicsAction;

import java.util.Map;


/**
 * Parent Action for all I Will Follow actions.
 *
 * <p>Adds the Leader and Follower properties to the set of basic properties.</p>
 */
public class IWillFollowAction extends PhysicsAction {
    
    /**
     * Gets the set of properties required by all IWillFollowActions
     *
     * @return Map containing the properties
     */
    public Map getRequiredProperties() {
        Map properties = super.getRequiredProperties();

        BooleanProperty leader = new BooleanProperty(false);
        properties.put("Leader", leader);
        
        BooleanProperty follower = new BooleanProperty(false);
        properties.put("Follower", follower);

        NumberProperty pathId = new NumberProperty(-1);
        properties.put("PathId", pathId);
        
        return properties;
    }

    
    /**
     * Gets the value of the Leader property
     *
     * @param to the concerned TextObject
     *
     * @return BooleanProperty whether this TextObject has the Leader property or not
     */
    public BooleanProperty isLeader(TextObject to) {
        return (BooleanProperty)to.getProperty("Leader");
    }
    
    
    /**
     * Gets the value of the Follower property
     *
     * @param to the concerned TextObject
     *
     * @return BooleanProperty whether this TextObject has the Follower property or not
     */
    public BooleanProperty isFollower(TextObject to) {
        return (BooleanProperty)to.getProperty("Follower");
    }
    
    /**
     * Gets the id of the path followed by the object.
     *
     * @param to the concerned TextObject
     *
     * @return NumberProperty the id of the path the object is on.
     */
    public Integer getPathId(TextObject to) {
      return new Integer((int)(((NumberProperty)to.getProperty("PathId")).get()));
    }
}
