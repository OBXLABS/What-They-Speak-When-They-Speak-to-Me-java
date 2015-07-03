/*
 Copyright (C) <2015>  <Jason Lewis>
  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the BSD 3 clause with added Attribution clause license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   BSD 3 clause with added Attribution clause License for more details.
   */
import java.util.ArrayList;
import java.awt.Point;

import net.nexttext.Book;
import net.nexttext.TextObject;

/**
 * An interface for TUIO events.
 */
public class SnakeTuioPath extends SnakePath {
  
    public SnakeTuioPath(PApplet pApplet, Book theBook) {
        book = theBook;
        pointDistance = 10.0;
    }
    
    /**
     * Creates a new instance of SnakeTouchPath with custom point distance
     *
     * @param component the component the mouse is added to
     * @param theBook the book the mouse is added to
     * @param ptDist the point distance
     */
    public SnakeTuioPath(PApplet pApplet, Book theBook, double ptDist) {
        book = theBook;
        pointDistance = ptDist;
    }

    /**
     * Adds the current point to the path if the mouse button 1 is pressed
     *
     * @param event the mouse event
     */
    public void mousePressed(int id, int x, int y) {
        //System.out.println("Start Pressed...");
        ArrayList path = new ArrayList();
        path.add(new Point(x, y));      
        
        synchronized (paths) {
            // button 1 was pressed, add the point to the path    
            paths.put(new Integer(id), path);
        }

        //System.out.println("End Pressed...");
    }

    
    /**
     * Clears the path if the mouse button 1 is released
     *
     * @param event the mouse event
     */
    public void mouseReleased(int id, int x, int y) {
        Integer path_id = new Integer(id);        
        synchronized (paths) {
            // button 1 was released, clear the path
            paths.remove(path_id);
            
            TextObject theLeader = getLeader(path_id);
            if (theLeader != null) {
                // clear the 'Leader' property
                setFollower(theLeader, false);
                unsetLeader(path_id);
            }
        }
    }
    
    
    /**
     * Updates the local mouse coordinates and adds points to the path
     *
     * @param event the mouse event
     */
    public void mouseDragged(int id, int x, int y) {
        int distance;
        Integer path_id = new Integer(id);
        synchronized (paths) {
            if (!paths.containsKey(path_id)) return; //make sure the path exists
            
            ArrayList path = (ArrayList)paths.get(path_id);            
            Point lastPoint = (Point)path.get(path.size()-1);
            distance = (int)lastPoint.distance(x, y);
            
            // add interpolating points up until the current point over the distance from the last path point
            for (int i=0; i < (int)(distance/pointDistance); i++) {
                path.add(new Point((int)((double)(x - lastPoint.x)/distance*pointDistance*(i+1) + lastPoint.x),
                                   (int)((double)(y - lastPoint.y)/distance*pointDistance*(i+1) + lastPoint.y)));
            }
        }
    }
}
