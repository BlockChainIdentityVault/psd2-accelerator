package de.adorsys.psd2.sandbox.xs2a.testdata.domain;

import java.math.BigDecimal;
import java.util.Currency;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class Amount {
  private Currency currency;
  private BigDecimal amount;
}
