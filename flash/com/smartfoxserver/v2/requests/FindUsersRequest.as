package com.smartfoxserver.v2.requests
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.exceptions.SFSValidationError;
	import com.smartfoxserver.v2.logging.Logger;
	import com.smartfoxserver.v2.entities.match.*
	
	/**
	 * Retrieves a list of users from the server which match the specified criteria.
	 * 
	 * <p>By providing a matching expression and a search scope (a Room, a Group or the entire Zone), SmartFoxServer can find those users
	 * matching the passed criteria and return them by means of the <em>userFindResult</em> event.</p>
	 * 
	 * @example	The following example looks for all the users whose "age" User Variable is greater than <code>29</code>:
	 * <listing version="3.0">
	 * 
	 * private function someMethod():void
	 * {
	 * 	sfs.addEventListener(SFSEvent.USER_FIND_RESULT, onUserFindResult);
	 * 	
	 * 	// Create a matching expression to find users with an "age" variable greater than 29:
	 * 	var exp:MatchExpression = new MatchExpression("age", NumberMatch.GREATER_THAN, 29);
	 * 	
	 * 	// Find the users
	 * 	sfs.send(new FindUsersRequest(exp));
	 * }
	 * 
	 * private function onUserFindResult(evt:SFSEvent):void
	 * {
	 * 	trace("Users found: " + evt.params.users);
	 * }
	 * </listing>
	 * 
	 * @see		com.smartfoxserver.v2.entities.match.MatchExpression MatchExpression
	 * @see		com.smartfoxserver.v2.SmartFox#event:userFindResult userFindResult event
	 */
	public class FindUsersRequest extends BaseRequest
	{
		/** @private */
		public static const KEY_EXPRESSION:String = "e"
		
		/** @private */
		public static const KEY_GROUP:String = "g"
		
		/** @private */
		public static const KEY_ROOM:String = "r"
		
		/** @private */
		public static const KEY_LIMIT:String = "l"
		
		/** @private */
		public static const KEY_FILTERED_USERS:String = "fu"
		
		private var _matchExpr:MatchExpression
		private var _target:*
		private var _limit:int
			
		/**
		 * Creates a new <em>FindUsersRequest</em> instance.
		 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
		 * 
		 * @param	expr	A matching expression that the system will use to retrieve the users.
		 * @param	target	The name of a Group or a single <em>Room</em> object where to search for matching users; if <code>null</code>, the search is performed in the whole Zone.
		 * @param	limit	The maximum size of the list of users that will be returned by the <em>userFindResult</em> event. If <code>0</code>, all the found users are returned.
		 * 
		 * @see		com.smartfoxserver.v2.SmartFox#send() SmartFox.send()
		 * @see		com.smartfoxserver.v2.entities.Room Room
		 * @see		com.smartfoxserver.v2.SmartFox#event:userFindResult userFindResult event
		 */
		public function FindUsersRequest(expr:MatchExpression, target:* = null, limit:int = 0) 
		{
			super(BaseRequest.FindUsers)
			
			_matchExpr = expr
			_target = target
			_limit = limit
		}
		
		/** @private */
		override public function validate(sfs:SmartFox):void
		{
			var errors:Array = []
			
			if (_matchExpr == null)
				errors.push("Missing Match Expression")
			
			if (errors.length > 0)
				throw new SFSValidationError("FindUsers request error", errors)
		}
		
		/** @private */
		override public function execute(sfs:SmartFox):void
		{
			_sfso.putSFSArray(KEY_EXPRESSION, _matchExpr.toSFSArray())
			
			if (_target != null)
			{
				if (_target is Room)
					_sfso.putInt(KEY_ROOM, (_target as Room).id)
				else if (_target is String)
					_sfso.putUtfString(KEY_GROUP, _target)
				else
					sfs.logger.warn("Unsupport target type for FindUsersRequest: " + _target) 
			}
				
			// 2^15 is already too many Users :)
			if (_limit > 0)
				_sfso.putShort(KEY_LIMIT, _limit) 
		}
	}
}