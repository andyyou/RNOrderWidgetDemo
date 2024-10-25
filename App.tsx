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
  TextInput,
} from 'react-native';

const {OrderWidgetModule} = NativeModules;
function App(): React.JSX.Element {
  const [amount, setAmount] = React.useState(299);

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
          <TextInput
            placeholder="金額"
            value={amount.toString()}
            onChangeText={text => setAmount(parseInt(text, 10))}
          />
          <Button
            title="更新"
            onPress={() => {
              OrderWidgetModule.updateState({
                estimatedFee: amount,
                carPlate: 'ABC-123',
                paymentMethod: '',
                last4CardNumber: null,
              });
            }}
          />
          <Button
            title="JS計時器"
            onPress={() => {
              let index = 0;
              const timer = setInterval(() => {
                OrderWidgetModule.updateState({
                  estimatedFee: index++,
                });
                if (index > 100) {
                  clearInterval(timer);
                }
              }, 1000);
            }}
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
