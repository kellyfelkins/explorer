defmodule Explorer.PolarsBackend.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]
  # Since Rustler 0.27.0, we need to change manually the mode for each env.
  # We want "debug" in dev and test because it's faster to compile.
  mode = if Mix.env() in [:dev, :test], do: :debug, else: :release

  use RustlerPrecompiled,
    otp_app: :explorer,
    version: version,
    base_url: "#{github_url}/releases/download/v#{version}",
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      riscv64gc-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-pc-windows-msvc
      x86_64-pc-windows-gnu
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
      x86_64-unknown-freebsd
    ),
    # We don't use any features of newer NIF versions, so 2.15 is enough.
    nif_versions: ["2.15"],
    mode: mode,
    force_build: System.get_env("EXPLORER_BUILD") in ["1", "true"]

  defstruct [:inner]

  def df_from_arrow_stream_pointer(_stream_ptr), do: err()
  def df_arrange(_df, _by, _reverse, _groups), do: err()
  def df_arrange_with(_df, _expressions, _directions, _groups), do: err()
  def df_concat_columns(_df, _others), do: err()
  def df_concat_rows(_df, _others), do: err()
  def df_distinct(_df, _subset, _selection), do: err()
  def df_drop(_df, _name), do: err()
  def df_drop_nils(_df, _subset), do: err()
  def df_dtypes(_df), do: err()
  def df_dump_csv(_df, _has_headers, _delimiter), do: err()
  def df_dump_ndjson(_df), do: err()
  def df_dump_parquet(_df, _compression), do: err()
  def df_dump_ipc(_df, _compression), do: err()
  def df_dump_ipc_stream(_df, _compression), do: err()
  def df_filter_with(_df, _operation, _groups), do: err()

  def df_from_csv(
        _filename,
        _infer_schema_length,
        _has_header,
        _stop_after_n_rows,
        _skip_rows,
        _projection,
        _sep,
        _rechunk,
        _columns,
        _dtypes,
        _encoding,
        _nil_vals,
        _parse_dates,
        _eol_delimiter
      ),
      do: err()

  def df_from_ipc(_filename, _columns, _projection), do: err()
  def df_from_ipc_stream(_filename, _columns, _projection), do: err()
  def df_from_ndjson(_filename, _infer_schema_length, _batch_size), do: err()

  def df_from_parquet(
        _filename,
        _stop_after_n_rows,
        _columns,
        _projection
      ),
      do: err()

  def df_from_series(_columns), do: err()
  def df_group_indices(_df, _column_names), do: err()
  def df_groups(_df, _column_names), do: err()
  def df_head(_df, _length, _groups), do: err()
  def df_join(_df, _other, _left_on, _right_on, _how, _suffix), do: err()

  def df_load_csv(
        _binary,
        _infer_schema_length,
        _has_header,
        _stop_after_n_rows,
        _skip_rows,
        _projection,
        _sep,
        _rechunk,
        _columns,
        _dtypes,
        _encoding,
        _nil_vals,
        _parse_dates,
        _eol_delimiter
      ),
      do: err()

  def df_load_ipc(_binary, _columns, _projection), do: err()
  def df_load_ipc_stream(_binary, _columns, _projection), do: err()
  def df_load_ndjson(_binary, _infer_schema_length, _batch_size), do: err()
  def df_load_parquet(_binary), do: err()

  def df_mask(_df, _mask), do: err()
  def df_mutate_with_exprs(_df, _exprs, _groups), do: err()
  def df_n_rows(_df), do: err()
  def df_names(_df), do: err()
  def df_pivot_longer(_df, _id_vars, _value_vars, _names_to, _values_to), do: err()
  def df_pivot_wider(_df, _id_columns, _pivot_column, _values_column, _names_prefix), do: err()
  def df_pull(_df, _name), do: err()
  def df_put_column(_df, _series), do: err()
  def df_rename_columns(_df, _old_new_pairs), do: err()
  def df_sample_frac(_df, _frac, _with_replacement, _shuffle, _seed, _groups), do: err()
  def df_sample_n(_df, _n, _with_replacement, _shuffle, _seed, _groups), do: err()
  def df_select(_df, _selection), do: err()
  def df_select_at_idx(_df, _idx), do: err()
  def df_shape(_df), do: err()
  def df_slice(_df, _offset, _length, _groups), do: err()
  def df_slice_by_indices(_df, _indices, _groups), do: err()
  def df_slice_by_series(_df, _series, _groups), do: err()
  def df_summarise_with_exprs(_df, _groups_exprs, _aggs_pairs), do: err()
  def df_tail(_df, _length, _groups), do: err()
  def df_to_csv(_df, _filename, _has_headers, _delimiter), do: err()
  def df_to_csv_cloud(_df, _ex_entry, _has_headers, _delimiter), do: err()
  def df_to_dummies(_df, _columns), do: err()
  def df_to_ipc(_df, _filename, _compression), do: err()
  def df_to_ipc_cloud(_df, _ex_entry, _compression), do: err()
  def df_to_ipc_stream(_df, _filename, _compression), do: err()
  def df_to_ipc_stream_cloud(_df, _ex_entry, _compression), do: err()
  def df_to_lazy(_df), do: err()
  def df_to_ndjson(_df, _filename), do: err()
  def df_to_ndjson_cloud(_df, _ex_entry), do: err()
  def df_to_parquet(_df, _filename, _compression), do: err()
  def df_to_parquet_cloud(_df, _ex_entry, _compression), do: err()
  def df_width(_df), do: err()
  def df_describe(_df, _percentiles), do: err()
  def df_nil_count(_df), do: err()

  # Expressions (for lazy queries)
  @multi_arity_expressions [slice: 2, slice: 3, log: 1, log: 2]

  # We first generate functions for known operations.
  for {op, arity} <- Explorer.Backend.LazySeries.operations() -- @multi_arity_expressions do
    args = Macro.generate_arguments(arity, __MODULE__)
    expr_op = :"expr_#{op}"
    def unquote(expr_op)(unquote_splicing(args)), do: err()
  end

  def expr_slice(_lazy_series, _offset, _length), do: err()
  def expr_slice_by_indices(_lazy_series, _series), do: err()

  def expr_log(_lazy_series, _base), do: err()
  def expr_log_natural(_lazy_series), do: err()

  # Then we generate for some specific expressions
  def expr_alias(_ex_expr, _alias_name), do: err()
  def expr_atom(_atom), do: err()
  def expr_boolean(_bool), do: err()
  def expr_date(_date), do: err()
  def expr_datetime(_datetime), do: err()
  def expr_describe_filter_plan(_df, _expr), do: err()
  def expr_float(_number), do: err()
  def expr_integer(_number), do: err()
  def expr_series(_series), do: err()
  def expr_string(_string), do: err()

  # LazyFrame
  def lf_collect(_df), do: err()
  def lf_describe_plan(_df, _optimized), do: err()
  def lf_drop(_df, _columns), do: err()
  def lf_dtypes(_df), do: err()
  def lf_fetch(_df, _n_rows), do: err()
  def lf_head(_df, _n_rows), do: err()
  def lf_names(_df), do: err()
  def lf_select(_df, _columns), do: err()
  def lf_tail(_df, _n_rows), do: err()
  def lf_slice(_df, _offset, _length), do: err()
  def lf_from_ipc(_filename), do: err()
  def lf_from_ndjson(_filename, _infer_schema_length, _batch_size), do: err()
  def lf_from_parquet(_filename, _stop_after_n_rows, _maybe_columns), do: err()
  def lf_from_parquet_cloud(_ex_s3_entry, _stop_after_n_rows, _maybe_columns), do: err()

  def lf_from_csv(
        _filename,
        _infer_schema_length,
        _has_header,
        _stop_after_n_rows,
        _skip_rows,
        _sep,
        _rechunk,
        _dtypes,
        _encoding,
        _nil_vals,
        _parse_dates,
        _eol_delimiter
      ),
      do: err()

  def lf_filter_with(_df, _expression), do: err()
  def lf_arrange_with(_df, _expressions, _directions), do: err()
  def lf_distinct(_df, _subset, _selection), do: err()
  def lf_mutate_with(_df, _exprs), do: err()
  def lf_summarise_with(_df, _groups, _aggs), do: err()
  def lf_rename_columns(_df, _column_pairs), do: err()
  def lf_drop_nils(_df, _column_pairs), do: err()
  def lf_pivot_longer(_df, _id_vars, _value_vars, _names_to, _values_to), do: err()
  def lf_join(_df, _other, _left_on, _right_on, _how, _suffix), do: err()
  def lf_concat_rows(_dfs), do: err()
  def lf_concat_columns(_df, _others), do: err()
  def lf_to_parquet(_df, _filename, _compression, _streaming), do: err()
  def lf_to_ipc(_df, _filename, _compression, _streaming), do: err()

  # Series
  def s_as_str(_s), do: err()
  def s_add(_s, _other), do: err()
  def s_and(_s, _s2), do: err()
  def s_argmax(_s), do: err()
  def s_argmin(_s), do: err()
  def s_argsort(_s, _descending?, _nils_last?), do: err()
  def s_cast(_s, _dtype), do: err()
  def s_categories(_s), do: err()
  def s_categorise(_s, _s_categories), do: err()
  def s_coalesce(_s, _other), do: err()
  def s_concat(_series_list), do: err()
  def s_contains(_s, _pattern), do: err()
  def s_cumulative_max(_s, _reverse), do: err()
  def s_cumulative_min(_s, _reverse), do: err()
  def s_cumulative_sum(_s, _reverse), do: err()
  def s_cumulative_product(_s, _reverse), do: err()
  def s_skew(_s, _bias), do: err()
  def s_correlation(_s1, _s2, _ddof), do: err()
  def s_covariance(_s1, _s2), do: err()
  def s_distinct(_s), do: err()
  def s_divide(_s, _other), do: err()
  def s_dtype(_s), do: err()
  def s_equal(_s, _rhs), do: err()
  def s_exp(_s), do: err()
  def s_abs(_s), do: err()
  def s_strptime(_s, _format_string), do: err()
  def s_strftime(_s, _format_string), do: err()
  def s_clip_integer(_s, _min, _max), do: err()
  def s_clip_float(_s, _min, _max), do: err()
  def s_fill_missing_with_strategy(_s, _strategy), do: err()
  def s_fill_missing_with_boolean(_s, _value), do: err()
  def s_fill_missing_with_bin(_s, _value), do: err()
  def s_fill_missing_with_float(_s, _value), do: err()
  def s_fill_missing_with_int(_s, _value), do: err()
  def s_fill_missing_with_atom(_s, _value), do: err()
  def s_fill_missing_with_date(_s, _value), do: err()
  def s_fill_missing_with_datetime(_s, _value), do: err()
  def s_format(_series_list), do: err()
  def s_greater(_s, _rhs), do: err()
  def s_greater_equal(_s, _rhs), do: err()
  def s_head(_s, _length), do: err()
  def s_is_finite(_s), do: err()
  def s_is_infinite(_s), do: err()
  def s_is_nan(_s), do: err()
  def s_is_not_null(_s), do: err()
  def s_is_null(_s), do: err()
  def s_less(_s, _rhs), do: err()
  def s_less_equal(_s, _rhs), do: err()
  def s_lstrip(_s, _string), do: err()
  def s_mask(_s, _filter), do: err()
  def s_max(_s), do: err()
  def s_mean(_s), do: err()
  def s_median(_s), do: err()
  def s_product(_s), do: err()
  def s_min(_s), do: err()
  def s_multiply(_s, _other), do: err()
  def s_n_chunks(_s), do: err()
  def s_n_distinct(_s), do: err()
  def s_name(_s), do: err()
  def s_nil_count(_s), do: err()
  def s_not(_s), do: err()
  def s_from_list_bool(_name, _val), do: err()
  def s_from_list_date(_name, _val), do: err()
  def s_from_list_time(_name, _val), do: err()
  def s_from_list_datetime(_name, _val, _precision), do: err()
  def s_from_list_duration(_name, _val, _precision), do: err()
  def s_from_list_f64(_name, _val), do: err()
  def s_from_list_i64(_name, _val), do: err()
  def s_from_list_u32(_name, _val), do: err()
  def s_from_list_str(_name, _val), do: err()
  def s_from_list_binary(_name, _val), do: err()
  def s_from_list_categories(_name, _val), do: err()
  def s_from_binary_f64(_name, _val), do: err()
  def s_from_binary_i32(_name, _val), do: err()
  def s_from_binary_i64(_name, _val), do: err()
  def s_from_binary_u8(_name, _val), do: err()
  def s_not_equal(_s, _rhs), do: err()
  def s_or(_s, _s2), do: err()
  def s_peak_max(_s), do: err()
  def s_peak_min(_s), do: err()
  def s_select(_pred, _on_true, _on_false), do: err()
  def s_pow(_s, _other), do: err()
  def s_log_natural(_s_argument), do: err()
  def s_log(_s_argument, _base_as_float), do: err()
  def s_quantile(_s, _quantile, _strategy), do: err()
  def s_quotient(_s, _rhs), do: err()
  def s_remainder(_s, _rhs), do: err()
  def s_rename(_s, _name), do: err()
  def s_reverse(_s), do: err()
  def s_round(_s, _decimals), do: err()
  def s_floor(_s), do: err()
  def s_ceil(_s), do: err()
  def s_rstrip(_s, _string), do: err()
  def s_rank(_s, _method, _descending, _seed), do: err()
  def s_sample_n(_s, _n, _replace, _shuffle, _seed), do: err()
  def s_sample_frac(_s, _frac, _replace, _shuffle, _seed), do: err()
  def s_series_equal(_s, _other, _null_equal), do: err()
  def s_size(_s), do: err()
  def s_slice(_s, _offset, _length), do: err()
  def s_slice_by_indices(_s, _indices), do: err()
  def s_slice_by_series(_s, _series), do: err()
  def s_sort(_s, _descending?, _nils_last?), do: err()
  def s_standard_deviation(_s), do: err()
  def s_strip(_s, _string), do: err()
  def s_subtract(_s, _other), do: err()
  def s_sum(_s), do: err()
  def s_tail(_s, _length), do: err()
  def s_shift(_s, _offset), do: err()
  def s_at(_s, _rhs), do: err()
  def s_at_every(_s, _n), do: err()
  def s_to_list(_s), do: err()
  def s_downcase(_s), do: err()
  def s_to_iovec(_s), do: err()
  def s_upcase(_s), do: err()
  def s_unordered_distinct(_s), do: err()
  def s_frequencies(_s), do: err()
  def s_cut(_s, _bins, _labels, _break_point_label, _category_label), do: err()
  def s_substring(_s, _offset, _length), do: err()

  def s_qcut(_s, _quantiles, _labels, _break_point_label, _category_label),
    do: err()

  def s_variance(_s), do: err()
  def s_window_max(_s, _window_size, _weight, _ignore_null, _min_periods), do: err()
  def s_window_mean(_s, _window_size, _weight, _ignore_null, _min_periods), do: err()
  def s_window_median(_s, _window_size, _weight, _ignore_null, _min_periods), do: err()
  def s_window_min(_s, _window_size, _weight, _ignore_null, _min_periods), do: err()
  def s_window_sum(_s, _window_size, _weight, _ignore_null, _min_periods), do: err()

  def s_window_standard_deviation(_s, _window_size, _weight, _ignore_null, _min_periods),
    do: err()

  def s_ewm_mean(_s, _alpha, _adjust, _min_periods, _ignore_nils), do: err()
  def s_in(_s, _other), do: err()
  def s_day_of_week(_s), do: err()
  def s_month(_s), do: err()
  def s_year(_s), do: err()
  def s_hour(_s), do: err()
  def s_minute(_s), do: err()
  def s_second(_s), do: err()
  def s_sin(_s), do: err()
  def s_cos(_s), do: err()
  def s_tan(_s), do: err()
  def s_asin(_s), do: err()
  def s_acos(_s), do: err()
  def s_atan(_s), do: err()

  defp err, do: :erlang.nif_error(:nif_not_loaded)
end
