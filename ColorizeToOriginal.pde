/*
 Copyright (C) <2015>  <Jason Lewis>
  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the BSD 3 clause with added Attribution clause license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   BSD 3 clause with added Attribution clause License for more details.
   */
import java.awt.Color;

import net.nexttext.TextObject;
import net.nexttext.behaviour.AbstractAction;
import net.nexttext.property.ColorProperty;
import net.nexttext.property.NumberProperty;

/**
 * Fades the color of an object to a new color over time.
 */
/* $Id$ */
public class ColorizeToOriginal extends AbstractAction {
     
    protected boolean applyToFill = true;
    protected boolean applyToStroke = false;
    
    /**
     * The Colorize action will only influence the fill colour.
     *
     * <p>This constructor is kept for code consistency with code that was
     * using Colorize prior to the implementation of the stroke property. </p>
     *
     * @param speed The speed factor at which the colorization is applied
     */
    public ColorizeToOriginal ( float speed ) {        
        this(speed, true, false);
    }
    
    /**
     * The Colorize action is applied to the given glyph colour component
     * (i.e. the stroke and/or the fill)
     * 
     * @param speed The speed factor at which the colorization is applied
     * @param fill Indicates if the action has to be processed on the fill
     * @param stroke Indicates if the action has to be processed on the stroke
     */
    public ColorizeToOriginal ( float speed, boolean fill, boolean stroke ) {        
        applyToFill = fill;
        applyToStroke = stroke;
        if (fill) {
            properties().init("SpeedFill", new NumberProperty(speed) );
        }
        if (stroke) {
            properties().init("SpeedStroke", new NumberProperty(speed) );
        }
    }
    
    public ActionResult behave(TextObject to) {
        
        boolean doneFill = false;
        boolean doneStroke = false;
        
        if (applyToFill) {
            doneFill =  fadeTo(to.getColor(), 
                               to.getColor().getOriginal(), 
                               (int)((NumberProperty)properties().get("SpeedFill")).get());
        }
        
        if (applyToStroke) {
            doneStroke =  fadeTo(to.getStrokeColor(), 
                                 to.getStrokeColor().getOriginal(), 
                                 (int)((NumberProperty)properties().get("SpeedStroke")).get());
        }
        
        if ((applyToFill==doneFill) && (applyToStroke==doneStroke))
            return new ActionResult (true, true, false);
        
        return new ActionResult(false, true, false);
    }
    
    protected boolean fadeTo( ColorProperty currentProp, Color target, int speed ) {
        
        Color currentCol = currentProp.get();
        
        int tR = target.getRed();
        int tG = target.getGreen();
        int tB = target.getBlue();
        int tA = target.getAlpha();

        int newR = fadeComponentTo( currentCol.getRed(),   tR, speed );
        int newG = fadeComponentTo( currentCol.getGreen(), tG, speed );
        int newB = fadeComponentTo( currentCol.getBlue(),  tB, speed );
        int newA = fadeComponentTo( currentCol.getAlpha(), tA, speed );

        currentProp.set(new Color(newR, newG, newB, newA));

        return (newR == tR && newG == tG && newB == tB && newA == tA);
    }
    
    private int fadeComponentTo( int component, int target, int speed ) {
        
        if ( component < target ) {
            component += speed;
            if ( component > target ) {
                component = target;
            }
        }
        else {
            component -= speed;
            if ( component < target ) {
                component = target;
            }
        }
        return component;
    }
}

