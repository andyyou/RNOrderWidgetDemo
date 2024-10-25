/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  View,
  Button,
  NativeModules,
} from 'react-native';

const {OrderWidgetModule} = NativeModules;
function App(): React.JSX.Element {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.row}>
          <Button
            title="開始"
            onPress={() =>
              OrderWidgetModule.startActivity({
                estimatedFee: 299,
                carPlate: 'REN-8765', // 可選
                last4CardNumber: '1234', // 可選
                paymentMethod: 'card', // 可選
                parkedAt: new Date().getTime(),
                chargedAt: null,
              })
            }
          />
          <Button
            title="停止"
            onPress={() => OrderWidgetModule.stopLiveActivity()}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default App;
