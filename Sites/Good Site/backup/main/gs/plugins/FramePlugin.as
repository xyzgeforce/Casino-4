﻿package gs.plugins
{
    import flash.display.*;
    import gs.*;

    public class FramePlugin extends TweenPlugin
    {
        public var frame:int;
        protected var _target:MovieClip;
        public static const VERSION:Number = 1.01;
        public static const API:Number = 1;

        public function FramePlugin()
        {
            this.propName = "frame";
            this.overwriteProps = ["frame"];
            this.round = true;
            return;
        }// end function

        override public function onInitTween(param1:Object, param2, param3:TweenLite) : Boolean
        {
            if (!(param1 is MovieClip) || isNaN(param2))
            {
                return false;
            }
            _target = param1 as MovieClip;
            this.frame = _target.currentFrame;
            addTween(this, "frame", this.frame, param2, "frame");
            return true;
        }// end function

        override public function set changeFactor(param1:Number) : void
        {
            updateTweens(param1);
            _target.gotoAndStop(this.frame);
            return;
        }// end function

    }
}
