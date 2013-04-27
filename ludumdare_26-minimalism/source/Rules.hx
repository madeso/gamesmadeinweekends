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
		if ( index == -1 ) return false;
		if ( board.getColor(index) != Color.None )
		{
			board.notice(index);
			return false;
		}
		
		if ( c != Color.None )
		{
			var i : Int = board.getIndex(index, -1, 0);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					return false;
				}
			}
			
			i = board.getIndex(index, 1, 0);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					return false;
				}
			}
			
			i = board.getIndex(index, 0, 1);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					return false;
				}
			}
			
			i = board.getIndex(index, 0, -1);
			if ( i != -1 )
			{
				if ( board.getColor(i) == c ) 
				{
					board.notice(i);
					return false;
				}
			}
		}
		
		return true;
	}
}