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

package com.freshplanet.ane.AirInAppPurchase {

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class InAppPurchase extends EventDispatcher {

		private var _context:ExtensionContext = null;
        private var _iosPendingPurchases:Vector.<Object> = new Vector.<Object>();

        private static const EXTENSION_ID:String = "com.freshplanet.AirInAppPurchase";

        private static var _instance:InAppPurchase = null;

		public function InAppPurchase(lock:SingletonLock) {

            if (!isSupported)
                return;

            _context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);

            if (!_context)
                throw Error("Extension context is null. Please check if extension.xml is setup correctly.");

            _context.addEventListener(StatusEvent.STATUS, _onStatus);
		}

        public static function get instance():InAppPurchase {

            if (!_instance)
                _instance = new InAppPurchase(new SingletonLock());

            return _instance;
        }

        public static function get isSupported():Boolean {
            return _isIOS() || _isAndroid();
        }

        private static function _isIOS():Boolean {
            return Capabilities.manufacturer.indexOf("iOS") > -1;
        }

        private static function _isAndroid():Boolean {
            return Capabilities.manufacturer.indexOf("Android") > -1;
        }

        /**
         * INIT_SUCCESSFUL
         * INIT_ERROR
         * @param googlePlayKey
         * @param debug
         */
		public function init(googlePlayKey:String, debug:Boolean = false):void {

            if (!isSupported)
                return;

            trace("[InAppPurchase] init library");
            _context.call("initLib", googlePlayKey, debug);
		}

        /**
         * PURCHASE_SUCCESSFUL
         * PURCHASE_ERROR
         * @param productId
         */
		public function makePurchase(productId:String, developerPayload: String = ""):void {

            if (!isSupported) {

                _dispatchEvent(InAppPurchaseEvent.PURCHASE_ERROR, "InAppPurchase not supported");
                return;
            }

            trace("[InAppPurchase] purchasing", productId, developerPayload);
            _context.call("makePurchase", productId, developerPayload);
		}

        /**
         * PURCHASE_SUCCESSFUL
         * PURCHASE_ERROR
         * @param productId
         */
        public function makeSubscription(productId:String):void {

            if (_isAndroid()) {

                trace("[InAppPurchase] check user can make a subscription");
                _context.call("makeSubscription", productId);
            }
            else {
                _dispatchEvent(InAppPurchaseEvent.PURCHASE_ERROR, "subscriptions not supported");
            }
        }
		
        /**
         * CONSUME_SUCCESSFUL
         * CONSUME_ERROR
         * @param productId
         * @param receipt
         */
		public function removePurchaseFromQueue(productId:String, receipt:String):void {

            if (!isSupported)
                return;

            trace("[InAppPurchase] removing product from queue", productId, receipt);
            _context.call("removePurchaseFromQueue", productId, receipt);

            if (Capabilities.manufacturer.indexOf("iOS") > -1) {

                var filterPurchase:Function = function(jsonPurchase:String, index:int, purchases:Vector.<Object>):Boolean {

                    try {

                        var purchase:Object = JSON.parse(jsonPurchase);
                        return JSON.stringify(purchase.receipt) != receipt;
                    }
                    catch (error:Error) {
                        trace("[InAppPurchase] Couldn't parse purchase: " + jsonPurchase);
                    }

                    return false;
                };

                _iosPendingPurchases = _iosPendingPurchases.filter(filterPurchase);

            }
		}

        /**
         * PRODUCT_INFO_RECEIVED
         * PRODUCT_INFO_ERROR
         * @param productsId
         * @param subscriptionIds
         */
		public function getProductsInfo(productsId:Array, subscriptionIds:Array):void {

            if (!isSupported) {

                _dispatchEvent(InAppPurchaseEvent.PRODUCT_INFO_ERROR, "InAppPurchase not supported");
                return;
            }

            trace("[InAppPurchase] get Products Info");
            _context.call("getProductsInfo", productsId, subscriptionIds);
		}

        /**
         * RESTORE_INFO_RECEIVED
         * RESTORE_INFO_ERROR
         */
		public function restoreTransactions():void {

			if (_isAndroid())
				_context.call("restoreTransaction");
			else if (_isIOS()) {

				var jsonPurchases:String = "[" + _iosPendingPurchases.join(",") + "]";
				var jsonData:String = "{ \"purchases\": " + jsonPurchases + "}";

                _dispatchEvent(InAppPurchaseEvent.RESTORE_INFO_RECEIVED, jsonData);
			}
		}

        /**
         *
         * @param type
         * @param eventData
         */
        private function _dispatchEvent(type:String, eventData:String):void {
            this.dispatchEvent(new InAppPurchaseEvent(type, eventData))
        }

        /**
         *
         * @param event
         */
		private function _onStatus(event:StatusEvent):void {

			trace(event);

            if (event.code == InAppPurchaseEvent.PURCHASE_SUCCESSFUL && _isIOS())
                _iosPendingPurchases.push(event.level);

            _dispatchEvent(event.code, event.level);
		}
	}
}

class SingletonLock {}