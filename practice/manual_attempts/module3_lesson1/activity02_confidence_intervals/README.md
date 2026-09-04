# Module 3 · Lesson 1 · Activity 2

## 95% confidence intervals under repeated sampling

## Goal

Construct confidence intervals for **500 repeated samples** and measure how
often the intervals contain the true population mean.

This follows the Fiocruz lesson's repeated-sampling interpretation of a 95%
confidence interval.

## Course setup represented here

The introductory derivation considers a Normal population with known variance:

\[
\bar X \sim N\left(\mu,\frac{\sigma^2}{n}\right)
\]

For a 95% confidence level:

\[
z_{0.975}\approx1.96
\]

and the interval for the population mean is:

\[
\bar x \pm 1.96\frac{\sigma}{\sqrt n}
\]

## Simulation

This portfolio-safe implementation uses a synthetic Normal population with:

- true mean `mu = 26`;
- known population SD `sigma = 4`;
- sample size `n = 100`;
- 500 repeated samples;
- 95% confidence level.

For every repeated sample, I calculated:

1. the sample mean;
2. the standard error;
3. the margin of error;
4. the lower and upper confidence limits;
5. whether the interval contained the true mean.

## Correct interpretation

A 95% confidence interval is best understood through repeated sampling.

If the same sampling-and-interval procedure were repeated many times, about
95% of the resulting intervals would contain the true population parameter.

After an individual interval has been calculated, the parameter is fixed and
the interval either contains it or it does not. The 95% refers to the long-run
performance of the procedure.

## Why some intervals miss

A valid 95% method is expected to miss the true parameter in roughly 5% of
repeated samples.

Those misses are not evidence that the method is broken. They are part of the
stated error rate of the procedure.

## Connection to the previous activity

The Central Limit Theorem provided the sampling distribution and standard
error of the sample mean.

That sampling distribution is what makes interval estimation possible.

## Outputs

### Figures

- `outputs/coverage_500_intervals.png`
- `outputs/coverage_first_100_intervals.png`
- `outputs/sampling_distribution_means.png`

### Tables

- `outputs/confidence_intervals_500.csv`
- `outputs/coverage_summary.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 2.

The course asks learners to construct confidence intervals for 500 samples and
observe that approximately 95% of 95% intervals capture the true population
mean. This is an original reproducible simulation implementing that concept.
