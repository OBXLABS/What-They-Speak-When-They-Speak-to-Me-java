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
import java.awt.event.MouseEvent;

import net.nexttext.Book;
import net.nexttext.TextObject;
import net.nexttext.TextObjectGroup;
import net.nexttext.TextObjectGlyph;
import net.nexttext.TextObjectGlyphIterator;
import net.nexttext.input.InputSource;
import net.nexttext.property.BooleanProperty;       

/**
 * An interface for the mouse. It listens to every mouse event and stores them in 
 * a list as {@link MouseEvent} objects.  It also keeps the current status of 
 * the mouse buttons and the current x and y position.</p>
 * 
 * <p>SnakeMousePath saves an array of the points when the mouse is dragged.
 * The points are spaced by a given distance and the array is reset
 * when the button is released.</p>
 *
 * <p>SnakeMousePath also registers and releases the 'Leader', by cycling through
 * the glyphs in the book and checking if any collide with the mouse coordinates
 * when dragged.</p> 
 */
public class SnakeMousePath extends SnakePath {
  
    private Integer path_id = new Integer(0);
  
    public SnakeMousePath(PApplet pApplet, Book theBook) {
        pApplet.registerMouseEvent(this);
        book = theBook;
        pointDistance = 10.0;
    }
    
    /**
     * Creates a new instance of SnakeMousePath with custom point distance
     *
     * @param component the component the mouse is added to
     * @param theBook the book the mouse is added to
     * @param ptDist the point distance
     */
    public SnakeMousePath(PApplet pApplet, Book theBook, double ptDist) {
        pApplet.registerMouseEvent(this);
        book = theBook;
        pointDistance = ptDist;
    }
    
    public void mouseEvent(MouseEvent event) {
        switch (event.getID()) {
            case MouseEvent.MOUSE_PRESSED:
                mousePressed(event);
                break;
            case MouseEvent.MOUSE_RELEASED:
                mouseReleased(event);
                break;
            case MouseEvent.MOUSE_DRAGGED:
                mouseDragged(event);
                break;
        }
    }

    
    /**
     * Adds the current point to the path if the mouse button 1 is pressed
     *
     * @param event the mouse event
     */
    public void mousePressed(MouseEvent event) {
        ArrayList path = new ArrayList();
        path.add(new Point(event.getX(), event.getY()));      

        synchronized (paths) {
            if (event.getButton() == MouseEvent.BUTTON1) {
                // button 1 was pressed, add the point to the path    
                paths.put(path_id, path);
            }
        }
    }

    
    /**
     * Clears the path if the mouse button 1 is released
     *
     * @param event the mouse event
     */
    public void mouseReleased(MouseEvent event) {
        synchronized (paths) {
            // button 1 was released, clear the path
            if (event.getButton() == MouseEvent.BUTTON1) {
                paths.remove(path_id);
                
                TextObject theLeader = getLeader(path_id);
                
                if (theLeader != null) {
                    // clear the 'Leader' property
                    setFollower(theLeader, false);
                    unsetLeader(path_id);

                }
            }
        }
    }
    
    
    /**
     * Updates the local mouse coordinates and adds points to the path
     *
     * @param event the mouse event
     */
    public void mouseDragged(MouseEvent event) {
        int distance;
        synchronized (paths) {
            if (!paths.containsKey(path_id)) return; //make sure the path exists
            
            ArrayList path = (ArrayList)paths.get(path_id);            
            Point lastPoint = (Point)path.get(path.size()-1);
            distance = (int)lastPoint.distance(event.getX(), event.getY());
            
            // add interpolating points up until the current point over the distance from the last path point
            for (int i=0; i < (int)(distance/pointDistance); i++) {
                path.add(new Point((int)((double)(event.getX() - lastPoint.x)/distance*pointDistance*(i+1) + lastPoint.x),
                                   (int)((double)(event.getY() - lastPoint.y)/distance*pointDistance*(i+1) + lastPoint.y)));
            }
        }
        
        // look for a collision with a glyph if there is no leader already set
        /*TextObject theLeader = getLeader(path_id);
        if ((theLeader == null) && (distance >= pointDistance)) {
           TextObjectGlyph currGlyph;
           
           TextObjectGlyphIterator i = book.getTextRoot().glyphIterator();
           while (i.hasNext()) {
               currGlyph = i.next();
               
               if (currGlyph.getBoundingPolygon().contains(event.getX(), event.getY())) {
                   // set the leader pointer
                   setLeader(currGlyph, path_id);
                   setFollower(currGlyph, true);
                   
                   break;
               }
           }
        }*/
    }
}
