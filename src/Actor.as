	package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class Actor extends Sprite {
		public var dx:Number = 0, dy:Number = 0, ddx:Number = 0, ddy:Number = 0;	// Velocity & acceleration
		public var w:int, h:int;	// Width/height
		public var angle:Number = 90;	// For determining "rotation"
		public var g:Graphics, color:Number;
		
		// variables for collision
		public var number_of_sides:int;
		public var points:Array;
		
		public function Actor(X:int, Y:int, Color:Number):void {
			g = graphics;
			w = 20; 
			h = 20;
			color = Color;
			x = X;
			y = Y;
			
			points = new Array();
			points.push(new Point(-(w>>1), -(h>>1)));	// Upper left
			points.push(new Point(w>>1, -(h>>1)));	// Upper right
			points.push(new Point(w>>1, h>>1));	// Lower right
			points.push(new Point(-(w>>1), h>>1));	// Lower left
			
			number_of_sides = points.length;
		}
		
		public function draw(g:Graphics):void 
		{
			//g.lineStyle(1, color);	// For outlines
			g.moveTo(points[number_of_sides - 1].x + x, points[number_of_sides - 1].y + y);
			g.lineStyle(0);
			g.beginFill(color);			// For solid color
			for each(var p:Object in points)
				g.lineTo(p.x + x, p.y + y);
			g.endFill();
		}
		
		public function collides_with(a:Actor):Object {
			var other:Object = { minimum: 0, maximum: 0 }
			var self:Object = { minimum: 0, maximum: 0 }
			var projection_vector:Object = { x: 0, y: 0 }
			var penetration_vector:Object = { x: 0, y: 0, length: -1 }		// The shortest vector used to "push" offending polys out
			var temp:Number;
			
			// Test sides of self
			for(var i:int = 0; i < number_of_sides; i++) {
				// Get vector to project onto - to speed this up, we could pre-calculate these normals when the poly is created
				if(i == 0) {
					// This is the normal, which is why you're assigning y values to x, etc.
					projection_vector.x = points[number_of_sides - 1].y - points[0].y;
					projection_vector.y = points[0].x - points[number_of_sides - 1].x;
				}
				else {
					projection_vector.x = points[i - 1].y - points[i].y;
					projection_vector.y = points[i].x - points[i - 1].x;
				}
				
				// Normalize this vector we're projecting on to
				var vector_length:Number = Math.sqrt(projection_vector.x * projection_vector.x + projection_vector.y * projection_vector.y);
				projection_vector.x /= vector_length;
				projection_vector.y /= vector_length;
				
				// Project each side onto the vector just calculated
				// Set the min/max to be the first projection (dot product)
				self.minimum = self.maximum = points[0].x * projection_vector.x + points[0].y * projection_vector.y;
				for(var j:int = 1; j < number_of_sides; j++) {
					temp = points[j].x * projection_vector.x + points[j].y * projection_vector.y;
					if(temp > self.maximum) self.maximum = temp;
					else if(temp < self.minimum) self.minimum = temp;
				}
				
				// Correct for local vs. global offset
				var offset:Number = x * projection_vector.x + y * projection_vector.y;
				self.minimum += offset;
				self.maximum += offset;
				
				// Project other poly onto projection vector
				other.minimum = other.maximum = a.points[0].x * projection_vector.x + a.points[0].y * projection_vector.y;
				for(j = 1; j < a.number_of_sides; j++) {
					temp = a.points[j].x * projection_vector.x + a.points[j].y * projection_vector.y;
					if(temp > other.maximum) other.maximum = temp;
					else if(temp < other.minimum) other.minimum = temp;
				}
				
				// Correct for local vs. global offset
				offset = a.x * projection_vector.x + a.y * projection_vector.y;
				other.minimum += offset;
				other.maximum += offset;
				
				// Test if lines intersect - if not, return false
				if(self.maximum < other.minimum || self.minimum > other.maximum)
					return false;
				else {
					var d0:Number = self.maximum - other.minimum;
					var d1:Number = other.maximum - self.minimum;
					var d:Number = (d0 < d1) ? -d0 : d1;
					
					var l2:Number = projection_vector.x * projection_vector.x + projection_vector.y * projection_vector.y;
					var m:Object = {
							x: projection_vector.x * (d / l2),
							y: projection_vector.y * (d / l2)
						};
						
					// Length of "penetration" vector
					var m2:Number = (d * d) / l2;
					
					if(penetration_vector.length < 0 || m2 < penetration_vector.length) {
						penetration_vector.length = m2;
						penetration_vector.x = m.x;
						penetration_vector.y = m.y;
					}
				}
			}
			
			// Test sides of other poly
			for(i = 0; i < a.number_of_sides; i++) {
				// Get vector to project onto - to speed this up, we could pre-calculate these normals when the poly is created
				if(i == 0) {
					// This is the normal, which is why you're assigning y values to x, etc.
					projection_vector.x = a.points[a.number_of_sides - 1].y - a.points[0].y;
					projection_vector.y = a.points[0].x - a.points[a.number_of_sides - 1].x;
				}
				else {
					projection_vector.x = a.points[i - 1].y - a.points[i].y;
					projection_vector.y = a.points[i].x - a.points[i - 1].x;
				}
				
				// Normalize this vector we're projecting on to
				vector_length = Math.sqrt(projection_vector.x * projection_vector.x + projection_vector.y * projection_vector.y);
				projection_vector.x /= vector_length;
				projection_vector.y /= vector_length;
				
				// Project each side onto the vector just calculated
				// Set the min/max to be the first projection (dot product)
				self.minimum = self.maximum = a.points[0].x * projection_vector.x + a.points[0].y * projection_vector.y;
				for(j = 1; j < a.number_of_sides; j++) {
					temp = a.points[j].x * projection_vector.x + a.points[j].y * projection_vector.y;
					if(temp > self.maximum) self.maximum = temp;
					else if(temp < self.minimum) self.minimum = temp;
				}
				
				// Correct for local vs. global offset
				offset = a.x * projection_vector.x + a.y * projection_vector.y;
				self.minimum += offset;
				self.maximum += offset;
				
				// Project other poly onto projection vector
				other.minimum = other.maximum = points[0].x * projection_vector.x + points[0].y * projection_vector.y;
				for(j = 1; j < a.number_of_sides; j++) {
					temp = points[j].x * projection_vector.x + points[j].y * projection_vector.y;
					if(temp > other.maximum) other.maximum = temp;
					else if(temp < other.minimum) other.minimum = temp;
				}
				
				// Correct for local vs. global offset
				offset = x * projection_vector.x + y * projection_vector.y;
				other.minimum += offset;
				other.maximum += offset;
				
				// Test if lines intersect - if not, return false
				if(self.maximum < other.minimum || self.minimum > other.maximum)
					return false;
				else {
					d0 = self.maximum - other.minimum;
					d1 = other.maximum - self.minimum;
					d = (d0 < d1) ? -d0 : d1;

					l2 = projection_vector.x * projection_vector.x + projection_vector.y * projection_vector.y;
					m = {
							x: projection_vector.x * (d / l2),
							y: projection_vector.y * (d / l2)
						};

					// Length of "penetration" vector
					m2 = (d * d) / l2;

					if(penetration_vector.length < 0 || m2 < penetration_vector.length) {
						penetration_vector.length = m2;
						penetration_vector.x = m.x;
						penetration_vector.y = m.y;
					}
				}
			}
			
			// If all else fails, there's a collision
			return penetration_vector;
		}
		
		/*public function collides_with(a:Actor):Boolean {
			var other:Object = { 
				left: a.x - (a.width / 2),
				right: a.x + (a.width / 2),
				top: a.y + (a.height / 2),
				bottom: a.y - (a.height / 2)
			};
			
			var self:Object = {
				left: x - (width / 2),
				right: x + (width / 2),
				top: y + (height / 2),
				bottom: y - (height / 2)
			};
			
			// Simple AABB collision detection
			if(other.left > self.right || other.right < self.left) return false;
			if(other.bottom > self.top || other.top < self.bottom) return false;
			
			// If still here, that means a collision - find the vector that will push the first object out of the second
			return true
		}*/
	}
}