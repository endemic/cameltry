package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class Player extends Sprite 
	{
		public var radius:int;
		public var dx:Number = 0, dy:Number = 0, ddx:Number = 0, ddy:Number = 0;	// Velocity & acceleration
		public var angle:Number = 90;	// For determining "rotation"
		public var g:Graphics, color:Number;
		
		public function Player(X:int, Y:int, Color:Number, Radius:int = 10):void 
		{
			g = graphics;
			radius = Radius;
			color = Color;
			x = X;
			y = Y;
		}
		
		public function draw(g:Graphics):void {
			g.lineStyle(1, color);	// For outlines
			//g.beginFill(color);			// For solid color
			g.drawCircle(x, y, radius);
			g.endFill();
		}
		
		public function collides_with (a:Actor):Object 
		{
			var other:Object = { minimum: 0, maximum: 0 }
			var self:Object = { minimum: 0, maximum: 0 }
			var projection_vector:Object = { x: 0, y: 0 }
			var penetration_vector:Object = { x: 0, y: 0, length: -1 }		// The shortest vector used to "push" offending polys out
			var temp:Number, i:int, j:int;		// counter variables, etc.
			var closest_point:Object = { key: 0, distance: 100000 };

			// Test sides of other poly
			for (i = 0; i < 4; i++) 
			{
				// Get vector to project onto - to speed this up, we could pre-calculate these normals when the poly is created
				// These are vector normals, which is why we're assigning y values to x, etc. (inverting them)
				
				if(i == 0) 
				{
					projection_vector.x = a.points[a.number_of_sides - 1].y - a.points[0].y;
					projection_vector.y = a.points[0].x - a.points[a.number_of_sides - 1].x;
				}
				else if(i < a.number_of_sides)	// Use side as projection vector
				{
					projection_vector.x = a.points[i - 1].y - a.points[i].y;
					projection_vector.y = a.points[i].x - a.points[i - 1].x;
				}
				else	// Use the closest point on poly and center of circle as projection vector
				{				
					projection_vector.x = a.points[closest_point.key].y - this.y;
					projection_vector.y = this.x - a.points[closest_point.key].x;
				}
				
				// Find point closest to center of self to test against later
				temp = Math.sqrt(Math.pow(a.points[i].x + a.x - self.x, 2) + Math.pow(a.points[i].y + a.y - self.y, 2));
				if(temp < closest_point.distance)
				{
					closest_point.distance = temp;
					closest_point.key = i;
				}
				
				// Normalize projection vector
				var vector_length:Number = Math.sqrt(projection_vector.x * projection_vector.x + projection_vector.y * projection_vector.y);
				projection_vector.x /= vector_length;
				projection_vector.y /= vector_length;
				
				// Project each point of self (circle) onto projection vector
				// Set min/max to be the first projection plus/minus circle radius
				//self.minimum = (this.x * projection_vector.x + this.y * projection_vector.y) - radius;
				//self.maximum = (this.x * projection_vector.x + this.y * projection_vector.y) + radius;
				
				// The previous was mistakenly adding global coordinates, when the other object was just using local ones
				self.minimum = -radius;
				self.maximum = radius;
				
				// Correct for local vs. global offset
				var offset:Number = this.x * projection_vector.x + this.y * projection_vector.y;
				self.minimum += offset;
				self.maximum += offset;
				
				// Project other poly onto projection vector
				// Set the min/max to be the first projection (dot product)
				other.minimum = other.maximum = a.points[0].x * projection_vector.x + a.points[0].y * projection_vector.y;
				for(j = 1; j < a.number_of_sides; j++) 
				{
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
			
			// If all else fails, there's a collision
			return penetration_vector;
		}
	}
}