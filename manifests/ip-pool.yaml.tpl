apiVersion: loadbalancer.harvesterhci.io/v1beta1
kind: IPPool
metadata:
  name: pool-${name}
  labels:
    loadbalancer.harvesterhci.io/global-ip-pool: 'false'
    loadbalancer.harvesterhci.io/vid: '${name}'
spec:
  ranges:
    - gateway: ${gateway}
      rangeEnd: ${range-end}
      rangeStart: ${range-start}
      subnet: ${subnet}
  selector:
    network: ${vlan-namespace}/${vlan}
#    scope:
#      - guestCluster: '*'
#        namespace: '*'
#        project: '*'
