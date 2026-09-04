# Module 3 · Lesson 1 · Activity 1

## Central Limit Theorem

## Goal

Simulate the **Central Limit Theorem (CLT)** by repeatedly sampling from a
strongly right-skewed population.

The Fiocruz activity asks the learner to generate **500 samples** and observe
how the distribution of sample means becomes approximately Normal even when
the original population is not Normal.

## Simulation design

I used an Exponential population with:

- theoretical mean: 26;
- theoretical standard deviation: 26.

I generated 500 independent samples at each of three sample sizes:

- `n = 5`;
- `n = 30`;
- `n = 100`.

For every sample, I calculated the sample mean.

## What the CLT says

For independent identically distributed observations with finite variance, the
sampling distribution of the sample mean becomes approximately Normal as
sample size increases.

Its expected center is the population mean:

\[
E(\bar X) = \mu
\]

and its standard error is:

\[
SE(\bar X) = \frac{\sigma}{\sqrt{n}}
\]

## What the simulation demonstrates

### The original population

The Exponential population is strongly right-skewed.

### n = 5

The sampling distribution of the mean still reflects substantial skewness and
has relatively large spread.

### n = 30

The distribution of sample means becomes more symmetric and concentrated.

### n = 100

The sample means are tightly concentrated around the population mean and the
sampling distribution is much more Normal-looking.

## Standard error

As sample size increases:

\[
SE = \frac{\sigma}{\sqrt{n}}
\]

decreases.

This means larger samples produce more precise estimates of the population
mean, all else being equal.

## Important distinction

The CLT does **not** say that the raw observations become Normally distributed
when the sample size grows.

It concerns the **sampling distribution of the estimator** — here, the sample
mean across repeated samples.

## Health-research lens

Researchers usually observe only one sample, not hundreds of repeated samples.

The sampling distribution is therefore a theoretical framework that allows us
to quantify uncertainty around an estimator. This becomes the basis for
confidence intervals and many hypothesis tests.

## Outputs

### Figures

- `outputs/original_skewed_population.png`
- `outputs/clt_sampling_distributions.png`
- `outputs/standard_error_by_sample_size.png`

### Tables

- `outputs/500_sample_means_by_n.csv`
- `outputs/clt_summary.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 1.

The official activity asks learners to simulate the Central Limit Theorem with
500 samples. This is an original reproducible implementation using a synthetic
Exponential population.
