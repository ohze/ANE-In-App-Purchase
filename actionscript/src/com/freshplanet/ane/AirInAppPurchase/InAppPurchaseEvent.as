//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirInAppPurchase
{
	import flash.events.Event;
	
	public class InAppPurchaseEvent extends Event
	{

		public static const INIT_SUCCESS:String = "initSuccess";
		public static const INIT_ERROR:String   = "initError";

		// init -> check if previously purchases not being processed by the app
		public static const PURCHASE_SUCCESS:String = "purchaseSuccess";
		public static const PURCHASE_ERROR:String   	= "purchaseError";
		public static const PURCHASE_ALREADY_OWNED:String = "purchaseAlreadyOwner";

		
		// user can make a purchase
		public static const PURCHASE_ENABLED:String = "purchaseEnabled";
		// user cannot make a purchase
		public static const PURCHASE_DISABLED:String = "purchaseDisabled";
		
		// user can make a subscription
		public static const SUBSCRIPTION_ENABLED:String = "subsEnabled";
		// user cannot make a subscription
		public static const SUBSCRIPTION_DISABLED:String = "subsDisabled";

		public static const PRODUCT_INFO_SUCCESS:String = "productInfoSuccess";
		public static const PRODUCT_INFO_ERROR:String = "productInfoError";

		public static const RESTORE_SUCCESS:String = "restoreSuccess";
		public static const RESTORE_ERROR:String = "restoreError";

		public static const CONSUME_SUCCESS:String = "restoreSuccess";
		public static const CONSUME_ERROR:String = "restoreError";



		// json encoded string (if any)
		public var data:String;
		
		public function InAppPurchaseEvent(type:String, data:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}