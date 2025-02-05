﻿package com.pixelfumes.reflect{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	
	public class Reflect extends MovieClip{
		//Created By Ben Pritchard of Pixelfumes 2007
		//Thanks to Mim, Jasper, Jason Merrill and all the others who 
		//have contributed to the improvement of this class
		
		//static var for the version of this class
		private static var VERSION:String = "4.0";
		//reference to the movie clip we are reflecting
		private var mc:Sprite;
		//the BitmapData object that will hold a visual copy of the mc
		private var mcBMP:BitmapData;
		//the BitmapData object that will hold the reflected image
		private var reflectionBMP:Bitmap;
		//the clip that will act as out gradient mask
		private var gradientMask_mc:MovieClip;
		//how often the reflection should update (if it is video or animated)
		private var updateInt:Number;
		//the size the reflection is allowed to reflect within
		private var bounds:Object;
		//the distance the reflection is vertically from the mc
		private var distance:Number = 0;
	
	
		function Reflect(args:Object){
			/*the args object passes in the following variables
			/we set the values of our internal vars to math the args*/
			//the clip being reflected
			mc = args.mc;
			//the alpha level of the reflection clip
			var alpha:Number = args.alpha/100;
			//the ratio opaque color used in the gradient mask
			var ratio:Number = args.ratio;
			//update time interval
			var updateTime:Number = args.updateTime;
			//the distance at which the reflection visually drops off at
			var reflectionDropoff:Number = args.reflectionDropoff;
			//the distance the reflection starts from the bottom of the mc
			var distance:Number = args.distance;
			
			//store width and height of the clip
			var mcHeight = mc.height;
			var mcWidth = mc.width;
			
			//store the bounds of the reflection
			bounds = new Object();
			bounds.width = mcWidth;
			bounds.height = mcHeight;
			
			//create the BitmapData that will hold a snapshot of the movie clip
			mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
			mcBMP.draw(mc);
			
			//create the BitmapData the will hold the reflection
			reflectionBMP = new Bitmap(mcBMP);
			//flip the reflection upside down
			reflectionBMP.scaleY = -1;
			//move the reflection to the bottom of the movie clip
			reflectionBMP.y = (bounds.height*2) + distance;
			
			//add the reflection to the movie clip's Display Stack
			var reflectionBMPRef:DisplayObject = mc.addChild(reflectionBMP);
			reflectionBMPRef.name = "reflectionBMP";
			
			//add a blank movie clip to hold our gradient mask
			var gradientMaskRef:DisplayObject = mc.addChild(new MovieClip());
			gradientMaskRef.name = "gradientMask_mc";
			
			//get a reference to the movie clip - cast the DisplayObject that is returned as a MovieClip
			gradientMask_mc = mc.getChildByName("gradientMask_mc") as MovieClip;
			//set the values for the gradient fill
			var fillType:String = GradientType.LINEAR;
		 	var colors:Array = [0xFFFFFF, 0xFFFFFF];
		 	var alphas:Array = [alpha, 0];
		  	var ratios:Array = [0, ratio];
			var spreadMethod:String = SpreadMethod.PAD;
			//create the Matrix and create the gradient box
		  	var matr:Matrix = new Matrix();
		  	//set the height of the Matrix used for the gradient mask
			var matrixHeight:Number;
			if (reflectionDropoff<=0) {
				matrixHeight = bounds.height;
			} else {
				matrixHeight = bounds.height/reflectionDropoff;
			}
			matr.createGradientBox(bounds.width, matrixHeight, (90/180)*Math.PI, 0, 0);
		  	//create the gradient fill
			gradientMask_mc.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
		    gradientMask_mc.graphics.drawRect(0,0,bounds.width,bounds.height);
			//position the mask over the reflection clip			
			gradientMask_mc.y = mc.getChildByName("reflectionBMP").y - mc.getChildByName("reflectionBMP").height;
			//cache clip as a bitmap so that the gradient mask will function
			gradientMask_mc.cacheAsBitmap = true;
			mc.getChildByName("reflectionBMP").cacheAsBitmap = true;
			//set the mask for the reflection as the gradient mask
			mc.getChildByName("reflectionBMP").mask = gradientMask_mc;
			
			//if we are updating the reflection for a video or animation do so here
			if(updateTime > -1){
				updateInt = setInterval(update, updateTime, mc);
			}
		}
		
		
		public function setBounds(w:Number,h:Number):void{
			//allows the user to set the area that the reflection is allowed
			//this is useful for clips that move within themselves
			bounds.width = w;
			bounds.height = h;
			gradientMask_mc.width = bounds.width;
			redrawBMP(mc);
		}
		public function redrawBMP(mc:Sprite):void {
			// redraws the bitmap reflection - Mim Gamiet [2006]
			mcBMP.dispose();
			mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
			mcBMP.draw(mc);
		}
		private function update(mc):void {
			//updates the reflection to visually match the movie clip
			mcBMP = new BitmapData(bounds.width, bounds.height, true, 0xFFFFFF);
			mcBMP.draw(mc);
			reflectionBMP.bitmapData = mcBMP;
		}
		public function destroy():void{
			//provides a method to remove the reflection
			if (mc.getChildByName("reflectionBMP") == null) {
				return;
			}
			mc.removeChild(mc.getChildByName("reflectionBMP"));
			reflectionBMP = null;
			mcBMP.dispose();
			clearInterval(updateInt);
			mc.removeChild(mc.getChildByName("gradientMask_mc"));
		}
	}
}