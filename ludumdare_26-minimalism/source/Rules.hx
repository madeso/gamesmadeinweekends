package ;

/**
 * ...
 * @author sirGustav
 */

class Rules 
{
	public static function IsValidBombColor(c:Color) : Bool
	{
		if ( c == Color.None || c == Color.Black ) return false;
		else return true;
	}
	
	public static function CanPlace(board:Board, index:Int, c:Color):Bool
	{
		var ret : Bool = true;
		if ( index == -1 ) return false;
		if ( board.getColor(index) != Color.None )
		{
			board.notice(index);
			ret = false;
		}
		
		if ( c != Color.None )
		{
			var i : Int = board.getIndex(index, -1, 0);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					ret = false;
				}
			}
			
			i = board.getIndex(index, 1, 0);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					ret = false;
				}
			}
			
			i = board.getIndex(index, 0, 1);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					ret = false;
				}
			}
			
			i = board.getIndex(index, 0, -1);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					ret = false;
				}
			}
		}
		
		return ret;
	}
}