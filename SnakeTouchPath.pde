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
 * <p>SnakeTouchPath saves an array of the points when the mouse is dragged.
 * The points are spaced by a given distance and the array is reset
 * when the button is released.</p>
 *
 * <p>SnakeTouchPath also registers and releases the 'Leader', by cycling through
 * the glyphs in the book and checking if any collide with the mouse coordinates
 * when dragged.</p> 
 */
public class SnakeTouchPath extends SnakePath implements TouchDelegate {
  
    public SnakeTouchPath(PApplet pApplet, Book theBook) {
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
    public SnakeTouchPath(PApplet pApplet, Book theBook, double ptDist) {
        book = theBook;
        pointDistance = ptDist;
    }
    
    public int OnTouchFrame(int frame_id, int time_stamp, Vector/*<TouchPoint>*/ point_list) {
        TouchPoint point;
        for(int i = 0; i < point_list.size(); i++)
        {
          point = (TouchPoint)point_list.elementAt(i);
          
          String message = "Touch";
          
          switch (point.m_point_event) {
            case PQMTClientConstant.TP_DOWN:
                message += " down";
                mousePressed(point);
                break;
            case PQMTClientConstant.TP_MOVE:
                message += " move";
                mouseDragged(point);
                break;
            case PQMTClientConstant.TP_UP:
                message += " up";
                mouseReleased(point);
                break;
          }

          message += " at "+point.m_x+" "+point.m_y+" with size "+point.m_dx+"*"+point.m_dy;
          ////System.out.println(message);
        }
    
        return PQMTClientConstant.PQ_MT_SUCESS;    
    }

    /**
     * Adds the current point to the path if the mouse button 1 is pressed
     *
     * @param event the mouse event
     */
    public void mousePressed(TouchPoint point) {
        //System.out.println("Start Pressed...");
        ArrayList path = new ArrayList();
        path.add(new Point(point.m_x, point.m_y));      
        
        synchronized (paths) {
            // button 1 was pressed, add the point to the path    
            paths.put(new Integer(point.m_id), path);
        }

        //System.out.println("End Pressed...");
    }

    
    /**
     * Clears the path if the mouse button 1 is released
     *
     * @param event the mouse event
     */
    public void mouseReleased(TouchPoint point) {
        Integer path_id = new Integer(point.m_id);        
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
    public void mouseDragged(TouchPoint point) {
        int distance;
        Integer path_id = new Integer(point.m_id);
        synchronized (paths) {
            if (!paths.containsKey(path_id)) return; //make sure the path exists
            
            ArrayList path = (ArrayList)paths.get(path_id);            
            Point lastPoint = (Point)path.get(path.size()-1);
            distance = (int)lastPoint.distance(point.m_x, point.m_y);
            
            // add interpolating points up until the current point over the distance from the last path point
            for (int i=0; i < (int)(distance/pointDistance); i++) {
                path.add(new Point((int)((double)(point.m_x - lastPoint.x)/distance*pointDistance*(i+1) + lastPoint.x),
                                   (int)((double)(point.m_y - lastPoint.y)/distance*pointDistance*(i+1) + lastPoint.y)));
            }
        }
        
        // look for a collision with a glyph if there is no leader already set
        /*TextObject theLeader = getLeader(path_id);
        if ((theLeader == null) && (distance >= pointDistance)) {
           TextObjectGlyph currGlyph;
           
           synchronized(book) {
             TextObjectGlyphIterator i = book.getTextRoot().glyphIterator();
             while (i.hasNext()) {
                 currGlyph = i.next();
                 if (currGlyph.getBoundingPolygon().contains(point.m_x, point.m_y)) {
                     // set the leader pointer
                     setLeader(currGlyph, path_id);
                     setFollower(currGlyph, true);
                     
                     break;
                 }
             }
           }
        }*/
    }
    
    public int OnTouchGesture(TouchGesture touch_gesture) {
        /*if(PQMTClientConstant.TG_NO_ACTION == touch_gesture.m_type) {
          return PQMTClientConstant.PQ_MT_SUCESS;
        }
    
        String message="Gesture "+touch_gesture.m_type + PQMTClient.GetGestureName(touch_gesture) +" come with params ";
        for (int i = 0; i < touch_gesture. m_params.size(); i++) {
          Double param = touch_gesture.m_params.get(i);
          message += param + " ";
        }
        message += "\n";
        //System.out.println(message);
        
        switch(touch_gesture.m_type)
        {
        case PQMTClientConstant.TG_DOWN:
          //imageCompent.startMove(touch_gesture.m_params.get(0).intValue(), touch_gesture.m_params.get(1).intValue());
          break;
        case PQMTClientConstant.TG_MOVE:
          //imageCompent.touchmove(touch_gesture.m_params.get(0).intValue(), touch_gesture.m_params.get(1).intValue());
          break;
        case PQMTClientConstant.TG_SPLIT_APART:
          //imageCompent.resize(1.05);
          //imageCompent.repaint();
          break;
        case PQMTClientConstant.TG_SPLIT_CLOSE:
          //imageCompent.resize(0.95);
          //imageCompent.repaint();
          break;
        // add case statement here to handle other gestures
        default:
          break;
        }*/
        return PQMTClientConstant.PQ_MT_SUCESS;
    }
}
