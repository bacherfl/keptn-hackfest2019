#!/bin/bash

KEPTN_PROJECT=$(cat creds.json | jq -r '.keptnProject')

frontend=skip
order_service=skip
catalog_service=skip
customer_service=skip

echo ""
echo "==================================================================="
echo "Please enter the image version to send, example: 1"
echo "Images with skip will not send an event"
echo "==================================================================="
read -p "frontend         (default:$frontend) : " frontend_new
read -p "order service    (default:$order_service) : " order_service_new
read -p "catalog service  (default:$catalog_service) : " catalog_service_new
read -p "customer service (default:$customer_service) : " customer_service_new

frontend=${frontend_new:-$frontend}
order_service=${order_service_new:-$order_service}
catalog_service=${catalog_service_new:-$catalog_service}
customer_service=${customer_service_new:-$customer_service}

if [ $frontend != "skip" ]; then
  echo ""
  echo "--------------------------------------------------------------------------"
  echo "keptn send event front-end:$frontend"
  echo "--------------------------------------------------------------------------"
  keptn send event new-artifact --project=$KEPTN_PROJECT --service=front-end --image=robjahn/keptn-orders-front-end --tag=$frontend
fi

if [ $order_service != "skip" ]; then
  echo ""
  echo "--------------------------------------------------------------------------"
  echo "keptn send event order-service:$order_service"
  echo "--------------------------------------------------------------------------"
  keptn send event new-artifact --project=$KEPTN_PROJECT --service=order-service --image=robjahn/keptn-orders-order-service --tag=$order_service
fi

if [ $catalog_service != "skip" ]; then
  echo ""
  echo "--------------------------------------------------------------------------"
  echo "keptn send event catalog-service:$catalog_service"
  echo "--------------------------------------------------------------------------"
  keptn send event new-artifact --project=$KEPTN_PROJECT --service=catalog-service --image=robjahn/keptn-orders-catalog-service --tag=$catalog_service
fi

if [ $customer_service != "skip" ]; then
  echo ""
  echo "--------------------------------------------------------------------------"
  echo "keptn send event customer-service:$customer_service"
  echo "--------------------------------------------------------------------------"
  keptn send event new-artifact --project=$KEPTN_PROJECT --service=customer-service --image=robjahn/keptn-orders-customer-service --tag=$customer_service
fi
